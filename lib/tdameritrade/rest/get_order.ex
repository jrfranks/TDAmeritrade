# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.GetOrder do
  @moduledoc """
  Retrieve a specific order by ID.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_order(Client.t() | binary(), String.t(), String.t() | integer()) ::
          {:ok, map()} | {:error, Error.t()}

  def get_order(client_or_user, account_id, order_id) when is_binary(account_id) do
    order_id_str = to_string(order_id)
    url = "/v1/accounts/#{account_id}/orders/#{order_id_str}"
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_order do
    {:error, Error.new_client_error(:missing_account_id_and_order_id)}
  end

  defmacro __using__(_) do
    quote do
      def get_order(account_id, order_id) when is_binary(account_id) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.GetOrder.get_order(client, account_id, order_id)
      end

      def get_order do
        try do
          TDAmeritrade.Rest.GetOrder.get_order()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
