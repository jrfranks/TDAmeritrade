# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.DeleteSavedOrder do
  @moduledoc """
  Delete a saved order.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec delete_saved_order(Client.t() | binary(), String.t(), String.t()) ::
          {:ok, map()} | {:error, Error.t()}

  def delete_saved_order(client_or_user, account_id, saved_order_id)
      when is_binary(account_id) and is_binary(saved_order_id) do
    client = TDAmeritrade.Rest.normalize(client_or_user)

    url = "/v1/accounts/#{account_id}/savedorders/#{saved_order_id}"

    case TDAmeritrade.Connection.delete(client, url) do
      {:ok, %HTTPoison.Response{status_code: status}} when status in [200, 204] ->
        {:ok, %{savedOrderId: saved_order_id, status: "DELETED"}}

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, Error.new(status, body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, Error.new_transport(reason)}

      other ->
        {:error, Error.new_client_error(:unexpected_response, other)}
    end
  end

  def delete_saved_order do
    {:error, Error.new_client_error(:missing_account_and_saved_order_id)}
  end

  defmacro __using__(_) do
    quote do
      def delete_saved_order(account_id, saved_order_id)
          when is_binary(account_id) and is_binary(saved_order_id) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.DeleteSavedOrder.delete_saved_order(client, account_id, saved_order_id)
      end

      def delete_saved_order do
        try do
          TDAmeritrade.Rest.DeleteSavedOrder.delete_saved_order()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
