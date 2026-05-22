# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.UpdateWatchlist do
  @moduledoc """
  Partially update an existing watchlist (PATCH semantics).
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec update_watchlist(Client.t() | binary(), String.t(), String.t(), map()) ::
          {:ok, map()} | {:error, Error.t()}

  def update_watchlist(client_or_user, account_id, watchlist_id, watchlist_body)
      when is_binary(account_id) and is_map(watchlist_body) do
    client = TDAmeritrade.Rest.normalize(client_or_user)

    url = "/v1/accounts/#{account_id}/watchlists/#{watchlist_id}"
    body = Poison.encode!(watchlist_body)
    headers = [{"Content-Type", "application/json"}]

    TDAmeritrade.Connection.patch(client, url, body, headers)
    |> Error.from_connection_result()
  end

  def update_watchlist do
    {:error, Error.new_client_error(:missing_account_watchlist_id_and_body)}
  end

  defmacro __using__(_) do
    quote do
      def update_watchlist(account_id, watchlist_id, watchlist_body)
          when is_binary(account_id) and is_map(watchlist_body) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)

        TDAmeritrade.Rest.UpdateWatchlist.update_watchlist(
          client,
          account_id,
          watchlist_id,
          watchlist_body
        )
      end

      def update_watchlist do
        try do
          TDAmeritrade.Rest.UpdateWatchlist.update_watchlist()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
