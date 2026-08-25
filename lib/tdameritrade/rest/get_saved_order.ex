# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Rest.GetSavedOrder do
  @moduledoc """
  Retrieve a specific saved order by ID.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_saved_order(Client.t() | binary(), String.t(), String.t()) ::
          {:ok, map()} | {:error, Error.t()}

  def get_saved_order(client_or_user, account_id, saved_order_id)
      when is_binary(account_id) and is_binary(saved_order_id) do
    url = "/v1/accounts/#{account_id}/savedorders/#{saved_order_id}"
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_saved_order do
    {:error, Error.new_client_error(:missing_account_and_saved_order_id)}
  end

  defmacro __using__(_) do
    quote do
      def get_saved_order(account_id, saved_order_id)
          when is_binary(account_id) and is_binary(saved_order_id) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.GetSavedOrder.get_saved_order(client, account_id, saved_order_id)
      end

      def get_saved_order do
        try do
          TDAmeritrade.Rest.GetSavedOrder.get_saved_order()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
