# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Stream.Real do
  @moduledoc """
  Production WebSocket-based TD Ameritrade streaming client.

  This module opens a real `wss://` connection to the TD streamer,
  performs the documented ADMIN LOGIN handshake, manages subscriptions,
  and delivers parsed market data using the exact same message contract
  as `TDAmeritrade.Stream.Offline`.

  ## Usage

      # 1. Obtain (or reuse) a Client with a valid access token
      client = TDAmeritrade.Client.new(access_token: "YOUR_TOKEN")

      # 2. Fetch the required streamer information
      {:ok, principals} =
        TDAmeritrade.Rest.GetUserPrincipals.get_user_principals(
          client,
          fields: "streamerSubscriptionKeys,streamerConnectionInfo"
        )

      # 3. Start the real streamer
      {:ok, streamer} = TDAmeritrade.Stream.Real.start_link(principals: principals)

      # 4. Subscribe (the streamer will queue until LOGIN succeeds)
      TDAmeritrade.Stream.Real.subscribe(streamer, "LEVELONE_EQUITY", "AAPL,MSFT", "0,1,2,3,4,5")

      # 5. Receive messages (identical shape to Offline)
      #    {:tda_stream_login, :success, %{...}}
      #    {:tda_stream, "LEVELONE_EQUITY", [ %{symbol: "AAPL", bid_price: ..., ...}, ... ] }

  The module reuses `TDAmeritrade.Stream.Commands` (including the new
  credential preparation helpers) and `TDAmeritrade.Stream.Parsers`.
  """

  use GenServer

  alias TDAmeritrade.Stream.Commands
  alias TDAmeritrade.Stream.Parsers
  alias TDAmeritrade.Rest.GetUserPrincipals

  require Logger

  # Client API -----------------------------------------------------------

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts)
  end

  def subscribe(server, service, keys, fields, subscriber \\ self()) do
    GenServer.cast(server, {:subscribe, service, keys, fields, subscriber})
  end

  def unsubscribe(server, service, keys, subscriber \\ self()) do
    GenServer.cast(server, {:unsubscribe, service, keys, subscriber})
  end

  def login_status(server) do
    GenServer.call(server, :login_status)
  end

  def close(server) do
    GenServer.cast(server, :close)
  end

  def quality_of_service(server, qos_level) when is_integer(qos_level) do
    GenServer.cast(server, {:qos, qos_level})
  end

  # GenServer callbacks --------------------------------------------------

  @impl true
  def init(opts) do
    state = %{
      subscriptions: %{},
      login_status: :pending,
      socket: nil,
      principals: nil,
      pending_subs: [],
      client: nil
    }

    send(self(), {:initialize, opts})
    {:ok, state}
  end

  @impl true
  def handle_info({:initialize, opts}, state) do
    principals =
      cond do
        principals = Keyword.get(opts, :principals) ->
          principals

        client = Keyword.get(opts, :client) ->
          case GetUserPrincipals.get_user_principals(client,
                 fields: "streamerSubscriptionKeys,streamerConnectionInfo"
               ) do
            {:ok, p} -> p
            _ -> nil
          end

        true ->
          nil
      end

    if principals do
      new_state = %{state | principals: principals, client: Keyword.get(opts, :client)}
      {:noreply, open_connection(new_state)}
    else
      Logger.warning("TDAmeritrade.Stream.Real started without principals or client")
      {:noreply, state}
    end
  end

  # Handle messages coming from WebSockex
  @impl true
  def handle_info({:web_socket_message, frame}, state) when is_binary(frame) do
    handle_incoming_frame(frame, state)
  end

  @impl true
  def handle_info({:web_socket_message, _other}, state), do: {:noreply, state}

  # Handle the registration of flushed subscriptions (sent via send(self(), ...))
  @impl true
  def handle_info({:register_sub, service, keys, fields, pid}, state) do
    {:noreply, add_subscription(state, service, keys, fields, pid)}
  end

  @impl true
  def handle_cast({:subscribe, service, keys, fields, pid}, state) do
    if match?({:success, _}, state.login_status) do
      send_subscribe_frame(state, service, keys, fields)
      {:noreply, add_subscription(state, service, keys, fields, pid)}
    else
      # Queue until we are logged in
      pending = [{service, keys, fields, pid} | state.pending_subs]
      {:noreply, %{state | pending_subs: pending}}
    end
  end

  @impl true
  def handle_cast({:unsubscribe, service, _keys, pid}, state) do
    subs = Map.get(state.subscriptions, service, [])
    new_subs = Enum.reject(subs, &(&1.pid == pid))

    new_state =
      if new_subs == [] do
        Map.put(state, :subscriptions, Map.delete(state.subscriptions, service))
      else
        put_in(state, [:subscriptions, service], new_subs)
      end

    {:noreply, new_state}
  end

  @impl true
  def handle_cast(:close, state) do
    if state.socket, do: WebSockex.cast(state.socket, :close)
    {:noreply, %{state | socket: nil}}
  end

  @impl true
  def handle_cast({:qos, qos_level}, state) do
    send_qos_frame(state, qos_level)
    {:noreply, state}
  end

  @impl true
  def handle_call(:login_status, _from, state) do
    {:reply, state.login_status, state}
  end

  # WebSocket connection handling ----------------------------------------

  defp open_connection(%{principals: principals} = state) do
    streamer_info = principals["streamerInfo"] || principals[:streamerInfo] || %{}

    raw_url =
      streamer_info["streamerSocketUrl"] || streamer_info[:streamerSocketUrl] ||
        "streamer-ws.tdameritrade.com"

    ws_url =
      if String.starts_with?(raw_url, "ws") do
        raw_url
      else
        "wss://" <> raw_url <> "/ws"
      end

    # Start the WebSockex process that will forward frames back to us
    {:ok, socket} =
      WebSockex.start_link(
        ws_url,
        TDAmeritrade.Stream.Real.SocketHandler,
        %{parent: self()},
        name: nil
      )

    # Build and send the LOGIN frame immediately
    login_frame = Commands.build_login_frame(principals)

    json = Poison.encode!(login_frame)
    WebSockex.send_frame(socket, {:text, json})

    %{state | socket: socket}
  end

  # Incoming frame processing (reuses the same logic as Offline) ---------

  defp handle_incoming_frame(raw_json, state) do
    decoded =
      case Poison.decode(raw_json) do
        {:ok, data} -> data
        _ -> %{}
      end

    parsed = Parsers.parse_message(decoded)
    messages = extract_messages(parsed)

    new_state =
      Enum.reduce(messages, state, fn item, acc ->
        service = item["service"] || item[:service] || "UNKNOWN"
        command = item["command"] || item[:command]
        content = item["content"] || item[:content] || item

        matching_subs = Map.get(acc.subscriptions, service, [])

        # Deep ADMIN LOGIN reaction (mirrors the improved Offline behaviour)
        acc =
          if service == "ADMIN" and command == "LOGIN" do
            c = content

            login_result =
              if Map.get(c, :success) == true or Map.get(c, "success") == true do
                server_id = to_string(Map.get(c, :msg) || Map.get(c, "msg") || "unknown")
                {:success, server_id}
              else
                reason =
                  Map.get(c, :reason) || Map.get(c, "reason") || Map.get(c, :msg) ||
                    Map.get(c, "msg") || "Login failed"

                {:denied, to_string(reason)}
              end

            # Notify ADMIN subscribers
            special = {:tda_stream_login, elem(login_result, 0), c}
            Enum.each(matching_subs, fn sub -> send(sub.pid, special) end)

            # Flush any queued subscriptions
            flushed_state = flush_pending_subscriptions(%{acc | login_status: login_result})

            %{flushed_state | login_status: login_result}
          else
            acc
          end

        # Deliver normal data to subscribers
        Enum.each(matching_subs, fn sub ->
          send(sub.pid, {:tda_stream, service, content})
        end)

        acc
      end)

    {:noreply, new_state}
  end

  defp extract_messages(%{"response" => list}) when is_list(list), do: list
  defp extract_messages(%{"data" => list}) when is_list(list), do: list
  defp extract_messages(%{"notify" => list}) when is_list(list), do: list
  defp extract_messages(list) when is_list(list), do: list
  defp extract_messages(map) when is_map(map), do: [map]
  defp extract_messages(_), do: []

  defp add_subscription(state, service, keys, fields, pid) do
    subs = Map.get(state.subscriptions, service, [])
    new_sub = %{pid: pid, keys: keys, fields: fields}
    new_subs = [new_sub | subs] |> Enum.uniq_by(& &1.pid)

    put_in(state, [:subscriptions, service], new_subs)
  end

  defp send_subscribe_frame(state, service, keys, fields) do
    if state.socket && state.principals do
      streamer_info = state.principals["streamerInfo"] || state.principals[:streamerInfo] || %{}
      app_id = streamer_info["appId"] || streamer_info[:appId] || ""

      account_id =
        get_in(state.principals, ["accounts", Access.at(0), "accountId"]) ||
          get_in(state.principals, [:accounts, Access.at(0), :accountId]) || ""

      sub_req = Commands.build_subscribe_request(service, 1, account_id, app_id, keys, fields)
      frame = Commands.wrap_requests([sub_req])

      json = Poison.encode!(frame)
      WebSockex.send_frame(state.socket, {:text, json})
    end

    :ok
  end

  defp send_qos_frame(state, qos_level) do
    if state.socket && state.principals do
      streamer_info = state.principals["streamerInfo"] || state.principals[:streamerInfo] || %{}
      app_id = streamer_info["appId"] || streamer_info[:appId] || ""

      account_id =
        get_in(state.principals, ["accounts", Access.at(0), "accountId"]) ||
          get_in(state.principals, [:accounts, Access.at(0), :accountId]) || ""

      qos_req = Commands.build_qos_request(1, account_id, app_id, qos_level)
      frame = Commands.wrap_requests([qos_req])

      json = Poison.encode!(frame)
      WebSockex.send_frame(state.socket, {:text, json})
    end

    :ok
  end

  defp flush_pending_subscriptions(state) do
    Enum.each(state.pending_subs, fn {service, keys, fields, pid} ->
      send_subscribe_frame(state, service, keys, fields)
      # also register the subscription
      send(self(), {:register_sub, service, keys, fields, pid})
    end)

    # Clear the queue
    %{state | pending_subs: []}
  end
end

# ----------------------------------------------------------------------
# Internal WebSockex handler (forwards frames to the Real GenServer)
# ----------------------------------------------------------------------
defmodule TDAmeritrade.Stream.Real.SocketHandler do
  use WebSockex

  require Logger

  def handle_frame({:text, msg}, %{parent: parent} = state) do
    send(parent, {:web_socket_message, msg})
    {:ok, state}
  end

  def handle_frame(_frame, state), do: {:ok, state}

  def handle_disconnect(%{reason: reason}, state) do
    Logger.warning("TDAmeritrade real streamer disconnected: #{inspect(reason)}")
    {:ok, state}
  end
end
