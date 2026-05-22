# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.GetWatchlist do
  @moduledoc """
  Retrieve a specific watchlist with all its items.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_watchlist(Client.t() | binary(), String.t(), String.t()) ::
          {:ok, map()} | {:error, Error.t()}

  def get_watchlist(client_or_user, account_id, watchlist_id)
      when is_binary(account_id) and is_binary(watchlist_id) do
    url = "/v1/accounts/#{account_id}/watchlists/#{watchlist_id}"
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_watchlist do
    {:error, Error.new_client_error(:missing_account_and_watchlist_id)}
  end

  defmacro __using__(_) do
    quote do
      def get_watchlist(account_id, watchlist_id)
          when is_binary(account_id) and is_binary(watchlist_id) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.GetWatchlist.get_watchlist(client, account_id, watchlist_id)
      end

      def get_watchlist do
        try do
          TDAmeritrade.Rest.GetWatchlist.get_watchlist()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
