# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Rest.GetStreamerSubscriptionKeys do
  @moduledoc """
  Get streamer subscription keys for accounts (needed for real-time streaming).
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_streamer_subscription_keys(Client.t() | binary(), list(String.t())) ::
          {:ok, map()} | {:error, Error.t()}

  def get_streamer_subscription_keys(client_or_user, accounts) when is_list(accounts) do
    accounts_param = Enum.join(accounts, ",")

    url =
      "/v1/userprincipals/streamersubscriptionkeys?accountIds=#{URI.encode_www_form(accounts_param)}"

    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_streamer_subscription_keys do
    {:error, Error.new_client_error(:missing_client_and_accounts)}
  end

  defmacro __using__(_) do
    quote do
      def get_streamer_subscription_keys(accounts) when is_list(accounts) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)

        TDAmeritrade.Rest.GetStreamerSubscriptionKeys.get_streamer_subscription_keys(
          client,
          accounts
        )
      end

      def get_streamer_subscription_keys do
        try do
          TDAmeritrade.Rest.GetStreamerSubscriptionKeys.get_streamer_subscription_keys()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
