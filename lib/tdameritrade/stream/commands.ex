# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Stream.Commands do
  @moduledoc """
  Pure functions for building the JSON command frames used by the
  TD Ameritrade streaming protocol.

  These functions produce the exact structure expected by the streamer
  (as documented in schemas/streaming-data.schema and the individual
  service modules).
  """

  @doc """
  Builds a standard request map for a given service/command.

  ## Examples

      iex> TDAmeritrade.Stream.Commands.build_request("ADMIN", "LOGIN", 0, "12345", "MYAPP", %{token: "abc", ...})
      %{
        "service" => "ADMIN",
        "command" => "LOGIN",
        "requestid" => 0,
        "account" => "12345",
        "source" => "MYAPP",
        "parameters" => %{"token" => "abc", ...}
      }
  """
  def build_request(service, command, request_id, account, source, parameters)
      when is_binary(service) and is_binary(command) do
    %{
      "service" => service,
      "command" => command,
      "requestid" => request_id,
      "account" => account,
      "source" => source,
      "parameters" => parameters
    }
  end

  @doc """
  Builds the LOGIN command frame for the ADMIN service.

  This must be the first command sent after opening a WebSocket connection.
  """
  def build_login_request(request_id, account_id, app_id, credentials)
      when is_map(credentials) do
    params = %{
      "token" => credentials["token"],
      "version" => "1.0",
      "credential" => credentials["credential"] || "",
      "appid" => app_id,
      "usergroup" => credentials["usergroup"] || "",
      "accesslevel" => credentials["accesslevel"] || "",
      "authorized" => "Y",
      "timestamp" => credentials["timestamp"],
      "acl" => credentials["acl"] || ""
    }

    build_request("ADMIN", "LOGIN", request_id, account_id, app_id, params)
  end

  @doc """
  Builds a QOS command frame.
  """
  def build_qos_request(request_id, account_id, app_id, qos_level)
      when is_integer(qos_level) do
    params = %{"qoslevel" => qos_level}

    build_request("ADMIN", "QOS", request_id, account_id, app_id, params)
  end

  @doc """
  Builds a SUBS (subscribe) command for a given service (LEVELONE, CHART, etc.).
  """
  def build_subscribe_request(service, request_id, account_id, app_id, keys, fields)
      when is_binary(service) and is_binary(keys) and is_binary(fields) do
    params = %{"keys" => keys, "fields" => fields}

    build_request(service, "SUBS", request_id, account_id, app_id, params)
  end

  @doc """
  Builds an UNSUBS (unsubscribe) command.
  """
  def build_unsubscribe_request(service, request_id, account_id, app_id, keys)
      when is_binary(service) and is_binary(keys) do
    params = %{"keys" => keys}

    build_request(service, "UNSUBS", request_id, account_id, app_id, params)
  end

  @doc """
  Wraps a list of request maps into the top-level "requests" envelope
  expected by the streamer.
  """
  def wrap_requests(requests) when is_list(requests) do
    %{"requests" => requests}
  end

  # ----------------------------------------------------------------------
  # Real WebSocket helpers (new for full real streamer)
  # ----------------------------------------------------------------------

  @doc """
  Prepares the credentials map required for a TD Ameritrade LOGIN request
  from a Get User Principals response.

  Performs the critical conversion of `tokenTimestamp` (ISO8601) into
  milliseconds since the Unix epoch, matching the official protocol and
  the reference Python implementation.

  Returns the map that should be passed through `URI.encode_query/1` to
  become the "credential" value inside the LOGIN parameters.
  """
  def prepare_streamer_credentials(user_principals) when is_map(user_principals) do
    streamer_info = user_principals["streamerInfo"] || user_principals[:streamerInfo] || %{}
    accounts = user_principals["accounts"] || user_principals[:accounts] || []
    first_account = List.first(accounts) || %{}

    token_timestamp = streamer_info["tokenTimestamp"] || streamer_info[:tokenTimestamp]

    timestamp_ms =
      case parse_token_timestamp(token_timestamp) do
        {:ok, dt} -> DateTime.to_unix(dt, :millisecond)
        _ -> 0
      end

    %{
      "userid" => first_account["accountId"] || first_account[:accountId] || "",
      "token" => streamer_info["token"] || streamer_info[:token] || "",
      "company" => first_account["company"] || first_account[:company] || "",
      "segment" => first_account["segment"] || first_account[:segment] || "",
      "cddomain" => first_account["accountCdDomainId"] || first_account[:accountCdDomainId] || "",
      "usergroup" => streamer_info["userGroup"] || streamer_info[:userGroup] || "",
      "accesslevel" => streamer_info["accessLevel"] || streamer_info[:accessLevel] || "",
      "authorized" => "Y",
      "timestamp" => timestamp_ms,
      "appid" => streamer_info["appId"] || streamer_info[:appId] || "",
      "acl" => streamer_info["acl"] || streamer_info[:acl] || ""
    }
  end

  defp parse_token_timestamp(nil), do: :error

  defp parse_token_timestamp(ts) when is_binary(ts) do
    # Handle both "Z" and offset forms
    ts = String.replace(ts, "Z", "+00:00")

    case DateTime.from_iso8601(ts) do
      {:ok, dt, _offset} -> {:ok, dt}
      _ -> :error
    end
  end

  defp parse_token_timestamp(_), do: :error

  @doc """
  Builds the complete LOGIN frame (the value that should be JSON-encoded
  and sent as the very first message after opening the WebSocket).

  This is the high-level helper used by the real WebSocket streamer.
  It reuses `build_login_request` and `wrap_requests`.
  """
  def build_login_frame(user_principals, request_id \\ 0) do
    creds_map = prepare_streamer_credentials(user_principals)

    # The "credential" field in the LOGIN parameters must be the urlencoded form
    encoded_credential = URI.encode_query(creds_map)

    # We also put the raw token at the top level of parameters (per protocol)
    token = creds_map["token"]

    streamer_info = user_principals["streamerInfo"] || user_principals[:streamerInfo] || %{}
    app_id = streamer_info["appId"] || streamer_info[:appId] || ""
    account_id = get_in(user_principals, ["accounts", Access.at(0), "accountId"]) || ""

    login_request =
      build_login_request(
        request_id,
        account_id,
        app_id,
        %{
          "token" => token,
          "credential" => encoded_credential,
          "usergroup" => creds_map["usergroup"],
          "accesslevel" => creds_map["accesslevel"],
          "acl" => creds_map["acl"],
          "timestamp" => creds_map["timestamp"]
        }
      )

    wrap_requests([login_request])
  end
end
