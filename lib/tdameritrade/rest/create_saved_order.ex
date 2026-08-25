# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Rest.CreateSavedOrder do
  @moduledoc """
  Create a new saved order (template for future placement).
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec create_saved_order(Client.t() | binary(), String.t(), map()) ::
          {:ok, map()} | {:error, Error.t()}

  def create_saved_order(client_or_user, account_id, saved_order_body)
      when is_binary(account_id) and is_map(saved_order_body) do
    url = "/v1/accounts/#{account_id}/savedorders"
    body = Poison.encode!(saved_order_body)
    headers = [{"Content-Type", "application/json"}]

    TDAmeritrade.Rest.post(client_or_user, url, body, headers)
  end

  def create_saved_order do
    {:error, Error.new_client_error(:missing_account_id_and_saved_order_body)}
  end

  defmacro __using__(_) do
    quote do
      def create_saved_order(account_id, saved_order_body)
          when is_binary(account_id) and is_map(saved_order_body) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)

        TDAmeritrade.Rest.CreateSavedOrder.create_saved_order(
          client,
          account_id,
          saved_order_body
        )
      end

      def create_saved_order do
        try do
          TDAmeritrade.Rest.CreateSavedOrder.create_saved_order()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
