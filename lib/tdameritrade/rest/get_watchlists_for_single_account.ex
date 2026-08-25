# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Rest.GetWatchlistsForSingleAccount do
  @moduledoc """
  List all watchlists for a specific account.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_watchlists_for_single_account(Client.t() | binary(), String.t()) ::
          {:ok, list(map())} | {:error, Error.t()}

  def get_watchlists_for_single_account(client_or_user, account_id) when is_binary(account_id) do
    url = "/v1/accounts/#{account_id}/watchlists"
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_watchlists_for_single_account do
    {:error, Error.new_client_error(:missing_account_id_and_client)}
  end

  defmacro __using__(_) do
    quote do
      def get_watchlists_for_single_account(account_id) when is_binary(account_id) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)

        TDAmeritrade.Rest.GetWatchlistsForSingleAccount.get_watchlists_for_single_account(
          client,
          account_id
        )
      end

      def get_watchlists_for_single_account do
        try do
          TDAmeritrade.Rest.GetWatchlistsForSingleAccount.get_watchlists_for_single_account()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
