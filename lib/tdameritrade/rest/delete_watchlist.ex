# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.DeleteWatchlist do
  @moduledoc """
  Delete a watchlist from an account.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec delete_watchlist(Client.t() | binary(), String.t(), String.t()) ::
          {:ok, map()} | {:error, Error.t()}

  def delete_watchlist(client_or_user, account_id, watchlist_id)
      when is_binary(account_id) and is_binary(watchlist_id) do
    client = TDAmeritrade.Rest.normalize(client_or_user)

    url = "/v1/accounts/#{account_id}/watchlists/#{watchlist_id}"

    case TDAmeritrade.Connection.delete(client, url) do
      {:ok, %HTTPoison.Response{status_code: status}} when status in [200, 204] ->
        {:ok, %{watchlistId: watchlist_id, status: "DELETED"}}

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, Error.new(status, body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, Error.new_transport(reason)}

      other ->
        {:error, Error.new_client_error(:unexpected_response, other)}
    end
  end

  def delete_watchlist do
    {:error, Error.new_client_error(:missing_account_and_watchlist_id)}
  end

  defmacro __using__(_) do
    quote do
      def delete_watchlist(account_id, watchlist_id)
          when is_binary(account_id) and is_binary(watchlist_id) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.DeleteWatchlist.delete_watchlist(client, account_id, watchlist_id)
      end

      def delete_watchlist do
        try do
          TDAmeritrade.Rest.DeleteWatchlist.delete_watchlist()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
