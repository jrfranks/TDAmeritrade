# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.CreateWatchlist do
  @moduledoc """
  Create a new watchlist for an account.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec create_watchlist(Client.t() | binary(), String.t(), map()) ::
          {:ok, map()} | {:error, Error.t()}

  def create_watchlist(client_or_user, account_id, watchlist_body)
      when is_binary(account_id) and is_map(watchlist_body) do
    url = "/v1/accounts/#{account_id}/watchlists"
    body = Poison.encode!(watchlist_body)
    headers = [{"Content-Type", "application/json"}]

    TDAmeritrade.Rest.post(client_or_user, url, body, headers)
  end

  def create_watchlist do
    {:error, Error.new_client_error(:missing_account_id_and_watchlist_body)}
  end

  defmacro __using__(_) do
    quote do
      def create_watchlist(account_id, watchlist_body)
          when is_binary(account_id) and is_map(watchlist_body) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.CreateWatchlist.create_watchlist(client, account_id, watchlist_body)
      end

      def create_watchlist do
        try do
          TDAmeritrade.Rest.CreateWatchlist.create_watchlist()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
