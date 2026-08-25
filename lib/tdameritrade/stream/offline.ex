# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Stream.Offline do
  @moduledoc """
  An offline/demo streaming client.

  This GenServer can be started without any network connection.
  It maintains subscriptions and can be fed pre-recorded incoming frames
  (via `push_frame/2`) for testing or demo purposes.

  It emits parsed messages to subscribers in the form:
      {:tda_stream, service, content}

  When an ADMIN LOGIN response is pushed (using the improved Parsers),
  it additionally emits a high-level handshake event to any ADMIN subscribers:

      {:tda_stream_login, :success, %{success: true, code: 0, msg: "...", reason: nil}}
      {:tda_stream_login, :denied, %{success: false, code: 3, msg: "Login Denied.", reason: "..."}}

  Query current state with `login_status/1`.

  Usage with the global singleton (convenient for demos):

      TDAmeritrade.Stream.Offline.start_link()
      TDAmeritrade.Stream.Offline.subscribe("ADMIN", "", [], self())
      TDAmeritrade.Stream.Offline.push_frame(login_frame)

  For isolated tests, start an anonymous instance:

      {:ok, pid} = TDAmeritrade.Stream.Offline.start_link(name: nil)
      TDAmeritrade.Stream.Offline.subscribe(pid, "QUOTE", "AAPL", "0,1,2,3", self())
  """

  use GenServer

  alias TDAmeritrade.Stream.Parsers

  # Client API

  def start_link(opts \\ []) do
    case Keyword.get(opts, :name, __MODULE__) do
      nil ->
        GenServer.start_link(__MODULE__, opts)

      name ->
        GenServer.start_link(__MODULE__, opts, name: name)
    end
  end

  def subscribe(server \\ __MODULE__, service, keys, fields, subscriber \\ self()) do
    GenServer.cast(server, {:subscribe, service, keys, fields, subscriber})
  end

  def unsubscribe(server \\ __MODULE__, service, keys, subscriber \\ self()) do
    GenServer.cast(server, {:unsubscribe, service, keys, subscriber})
  end

  @doc """
  Inject a frame into the offline streamer (for testing/demo).

  The frame can be:
  - a raw JSON string (will be decoded and parsed)
  - a map (already decoded; will be parsed)

  ADMIN LOGIN frames cause both the normal emission and the special
  `{:tda_stream_login, :success | :denied, parsed_content}` event.
  """
  def push_frame(server \\ __MODULE__, frame) do
    GenServer.cast(server, {:push_frame, frame})
  end

  @doc """
  Returns the current login handshake state observed from ADMIN responses.

  Possible values:
    :pending
    {:success, server_id}
    {:denied, reason}
  """
  def login_status(server \\ __MODULE__) do
    GenServer.call(server, :login_status)
  end

  def quality_of_service(_server \\ __MODULE__, qos_level) when is_integer(qos_level) do
    # Offline mode: no real network call; this is a no-op for symmetry with Real.
    :ok
  end

  # Server Callbacks

  @impl true
  def init(_opts) do
    {:ok, %{subscriptions: %{}, login_status: :pending}}
  end

  @impl true
  def handle_cast({:subscribe, service, keys, fields, pid}, state) do
    subs = Map.get(state.subscriptions, service, [])

    new_sub = %{pid: pid, keys: keys, fields: fields}
    new_subs = [new_sub | subs] |> Enum.uniq_by(& &1.pid)

    new_state = put_in(state, [:subscriptions, service], new_subs)
    {:noreply, new_state}
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
  def handle_cast({:push_frame, frame}, state) do
    decoded = decode_frame(frame)
    parsed = Parsers.parse_message(decoded)

    messages = extract_messages(parsed)

    new_state =
      Enum.reduce(messages, state, fn item, acc ->
        service = item["service"] || item[:service] || "UNKNOWN"
        command = item["command"] || item[:command]

        matching_subs = Map.get(acc.subscriptions, service, [])

        content = item["content"] || item[:content] || item

        # Special deep hook for ADMIN LOGIN handshake
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

            # Notify ADMIN subscribers with the friendly high-level event
            special = {:tda_stream_login, elem(login_result, 0), c}
            Enum.each(matching_subs, fn sub -> send(sub.pid, special) end)

            %{acc | login_status: login_result}
          else
            acc
          end

        # Always deliver the normal parsed content for any service
        Enum.each(matching_subs, fn sub ->
          send(sub.pid, {:tda_stream, service, content})
        end)

        acc
      end)

    {:noreply, new_state}
  end

  @impl true
  def handle_call(:login_status, _from, state) do
    {:reply, state.login_status, state}
  end

  # Internal Helpers

  defp decode_frame(frame) when is_binary(frame) do
    case Poison.decode(frame) do
      {:ok, data} -> data
      {:error, _} -> %{"service" => "UNKNOWN", "raw" => frame}
    end
  end

  defp decode_frame(frame) when is_map(frame), do: frame
  defp decode_frame(other), do: %{"service" => "UNKNOWN", "raw" => other}

  # Turn the result of Parsers.parse_message into a flat list of individual items
  # that we can iterate over. Handles the "response", "data", and direct cases.
  defp extract_messages(%{"response" => list}) when is_list(list), do: list
  defp extract_messages(%{"data" => list}) when is_list(list), do: list
  defp extract_messages(%{"notify" => list}) when is_list(list), do: list
  defp extract_messages(list) when is_list(list), do: list
  defp extract_messages(map) when is_map(map), do: [map]
  defp extract_messages(_), do: []
end
