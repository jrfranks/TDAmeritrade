# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.ReplaceWatchlist do
  @moduledoc """
  Completely replace an existing watchlist.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec replace_watchlist(Client.t() | binary(), String.t(), String.t(), map()) ::
          {:ok, map()} | {:error, Error.t()}

  def replace_watchlist(client_or_user, account_id, watchlist_id, watchlist_body)
      when is_binary(account_id) and is_map(watchlist_body) do
    client = TDAmeritrade.Rest.normalize(client_or_user)

    url = "/v1/accounts/#{account_id}/watchlists/#{watchlist_id}"
    body = Poison.encode!(watchlist_body)
    headers = [{"Content-Type", "application/json"}]

    TDAmeritrade.Connection.put(client, url, body, headers)
    |> Error.from_connection_result()
  end

  def replace_watchlist do
    {:error, Error.new_client_error(:missing_account_watchlist_id_and_body)}
  end

  defmacro __using__(_) do
    quote do
      def replace_watchlist(account_id, watchlist_id, watchlist_body)
          when is_binary(account_id) and is_map(watchlist_body) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)

        TDAmeritrade.Rest.ReplaceWatchlist.replace_watchlist(
          client,
          account_id,
          watchlist_id,
          watchlist_body
        )
      end

      def replace_watchlist do
        try do
          TDAmeritrade.Rest.ReplaceWatchlist.replace_watchlist()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
