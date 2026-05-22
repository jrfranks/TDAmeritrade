# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.GetPreferences do
  @moduledoc """
  Retrieve trading preferences for an account.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_preferences(Client.t() | binary(), String.t()) :: {:ok, map()} | {:error, Error.t()}

  def get_preferences(client_or_user, account_id) when is_binary(account_id) do
    url = "/v1/accounts/#{account_id}/preferences"
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_preferences do
    {:error, Error.new_client_error(:missing_account_id_and_client)}
  end

  defmacro __using__(_) do
    quote do
      def get_preferences(account_id) when is_binary(account_id) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.GetPreferences.get_preferences(client, account_id)
      end

      def get_preferences do
        try do
          TDAmeritrade.Rest.GetPreferences.get_preferences()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
