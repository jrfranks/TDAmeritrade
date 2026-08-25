# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Rest.GetWatchlistsForMultipleAccounts do
  @moduledoc """
  List watchlists across multiple accounts.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_watchlists_for_multiple_accounts(Client.t() | binary()) ::
          {:ok, list(map())} | {:error, Error.t()}

  def get_watchlists_for_multiple_accounts(client_or_user) do
    TDAmeritrade.Rest.get(client_or_user, "/v1/accounts/watchlists")
  end

  defmacro __using__(_) do
    quote do
      def get_watchlists_for_multiple_accounts do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)

        TDAmeritrade.Rest.GetWatchlistsForMultipleAccounts.get_watchlists_for_multiple_accounts(
          client
        )
      end
    end
  end
end
