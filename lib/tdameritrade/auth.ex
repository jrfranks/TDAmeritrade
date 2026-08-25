# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Auth do
  @moduledoc """
  Token storage for the legacy high-level API surface (`use TDAmeritrade`).

  In the modern demo path, you should prefer constructing a `%TDAmeritrade.Client{}`
  directly. This module exists only to keep the old flat API working via `put_token/2`.
  """

  use Agent

  def start_link(_opts \\ []) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Demo / test helper.

  Stores a pre-obtained access token under the given user key so that the
  legacy high-level API (TDAmeritrade.get_*(...)) and the old Connection
  helpers continue to work.
  """
  @spec put_token(String.t(), String.t()) :: :ok
  def put_token(user, token) when is_binary(user) and is_binary(token) do
    creds = %{access_token: token, token_type: "Bearer", expires_in: 1800}
    entry = %{refcount: 1, user: user, credentials: creds, cookies: nil}

    Agent.update(__MODULE__, fn state ->
      Map.put(state, user, entry)
    end)

    :ok
  end

  @spec logout(Map.t()) :: :ok
  def logout(user_info) do
    active_clients = Agent.get(__MODULE__, & &1)

    case Map.get(active_clients, user_info.user) do
      nil ->
        :ok

      info ->
        if info.refcount > 1 do
          new_info = %{info | refcount: info.refcount - 1}
          Agent.update(__MODULE__, &Map.put(&1, new_info.user, new_info))
        else
          Agent.update(__MODULE__, &Map.delete(&1, info.user))
        end
    end

    :ok
  end

  @spec client(binary) :: any()
  def client(user) do
    user_info = Agent.get(__MODULE__, &Map.get(&1, user))
    if user_info, do: user_info.credentials, else: nil
  end

  @spec stop() :: :ok
  def stop() do
    if Process.whereis(__MODULE__), do: Agent.stop(__MODULE__), else: :ok
  end

  # ----------------------------------------------------------------------
  # Legacy browser login code below this line has been removed / stubbed
  # because it was broken and is no longer supported.
  # All calls to the old login path now raise a clear error.
  # ----------------------------------------------------------------------

  @spec login(String.t()) :: no_return()
  def login(_user) do
    raise "Legacy TD Ameritrade browser login (TDAmeritrade.login/1) is no longer supported. Use TDAmeritrade.Auth.put_token/2 + Client instead."
  end
end
