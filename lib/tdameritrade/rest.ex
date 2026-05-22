# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -
defmodule TDAmeritrade.Rest do
  @moduledoc """
  Shared helpers for the modern `TDAmeritrade.Rest.*` endpoint modules.

  This module is the single source of truth for:
  - Normalizing legacy binary "user" tokens into `%TDAmeritrade.Client{}` structs
  - Common HTTP verb wrappers that automatically apply `Error.from_connection_result/1`

  It exists purely to eliminate the previous 30× duplication of `normalize_client/1`
  across every REST implementation.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @doc """
  Converts either a modern `%TDAmeritrade.Client{}` or a legacy binary user key
  into a proper Client struct.

  This is what allows the old `TDAmeritrade.get_quote("myuser", "AAPL")` style
  calls to keep working while new code uses the clean Client API.
  """
  @spec normalize(Client.t() | binary() | term()) :: Client.t()
  def normalize(%Client{} = c), do: c
  def normalize(user) when is_binary(user), do: Client.new(user: user)
  def normalize(_), do: Client.new()

  @doc "Convenience GET that normalizes the client and converts the result via Error."
  def get(client_or_user, path) do
    client = normalize(client_or_user)

    TDAmeritrade.Connection.get(client, path)
    |> Error.from_connection_result()
  end

  @doc "Convenience POST (with optional body and headers)."
  def post(client_or_user, path, body \\ "", headers \\ []) do
    client = normalize(client_or_user)

    TDAmeritrade.Connection.post(client, path, body, headers)
    |> Error.from_connection_result()
  end

  @doc "Convenience PUT."
  def put(client_or_user, path, body \\ "", headers \\ []) do
    client = normalize(client_or_user)

    TDAmeritrade.Connection.put(client, path, body, headers)
    |> Error.from_connection_result()
  end

  @doc "Convenience PATCH."
  def patch(client_or_user, path, body \\ "", headers \\ []) do
    client = normalize(client_or_user)

    TDAmeritrade.Connection.patch(client, path, body, headers)
    |> Error.from_connection_result()
  end

  @doc "Convenience DELETE."
  def delete(client_or_user, path) do
    client = normalize(client_or_user)

    TDAmeritrade.Connection.delete(client, path)
    |> Error.from_connection_result()
  end
end
