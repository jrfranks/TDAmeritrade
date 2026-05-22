# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.UpdatePreferences do
  @moduledoc """
  Update trading preferences for an account.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec update_preferences(Client.t() | binary(), String.t(), map()) ::
          {:ok, map()} | {:error, Error.t()}

  def update_preferences(client_or_user, account_id, preferences_body)
      when is_binary(account_id) and is_map(preferences_body) do
    url = "/v1/accounts/#{account_id}/preferences"
    body = Poison.encode!(preferences_body)
    headers = [{"Content-Type", "application/json"}]

    TDAmeritrade.Rest.put(client_or_user, url, body, headers)
  end

  def update_preferences do
    {:error, Error.new_client_error(:missing_account_id_and_preferences_body)}
  end

  defmacro __using__(_) do
    quote do
      def update_preferences(account_id, preferences_body)
          when is_binary(account_id) and is_map(preferences_body) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)

        TDAmeritrade.Rest.UpdatePreferences.update_preferences(
          client,
          account_id,
          preferences_body
        )
      end

      def update_preferences do
        try do
          TDAmeritrade.Rest.UpdatePreferences.update_preferences()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
