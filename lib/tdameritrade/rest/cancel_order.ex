# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Rest.CancelOrder do
  @moduledoc """
  Cancel a specific order for an account.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec cancel_order(Client.t() | binary(), String.t(), String.t() | integer()) ::
          {:ok, map()} | {:error, Error.t()}

  def cancel_order(client_or_user, account_id, order_id) when is_binary(account_id) do
    client = TDAmeritrade.Rest.normalize(client_or_user)
    order_id_str = to_string(order_id)

    url = "/v1/accounts/#{account_id}/orders/#{order_id_str}"

    # DELETE usually returns 200 or 204 on success with no body
    case TDAmeritrade.Connection.delete(client, url) do
      {:ok, %HTTPoison.Response{status_code: status}} when status in [200, 204] ->
        {:ok, %{orderId: order_id, status: "CANCELED"}}

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, Error.new(status, body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, Error.new_transport(reason)}

      other ->
        {:error, Error.new_client_error(:unexpected_response, other)}
    end
  end

  def cancel_order do
    {:error, Error.new_client_error(:missing_account_and_order_id)}
  end

  defmacro __using__(_) do
    quote do
      def cancel_order(account_id, order_id) when is_binary(account_id) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.CancelOrder.cancel_order(client, account_id, order_id)
      end

      def cancel_order do
        try do
          TDAmeritrade.Rest.CancelOrder.cancel_order()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
