# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Rest.ReplaceSavedOrder do
  @moduledoc """
  Replace an existing saved order.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec replace_saved_order(Client.t() | binary(), String.t(), String.t(), map()) ::
          {:ok, map()} | {:error, Error.t()}

  def replace_saved_order(client_or_user, account_id, saved_order_id, saved_order_body)
      when is_binary(account_id) and is_map(saved_order_body) do
    client = TDAmeritrade.Rest.normalize(client_or_user)

    url = "/v1/accounts/#{account_id}/savedorders/#{saved_order_id}"
    body = Poison.encode!(saved_order_body)
    headers = [{"Content-Type", "application/json"}]

    TDAmeritrade.Connection.put(client, url, body, headers)
    |> Error.from_connection_result()
  end

  def replace_saved_order do
    {:error, Error.new_client_error(:missing_account_saved_order_id_and_body)}
  end

  defmacro __using__(_) do
    quote do
      def replace_saved_order(account_id, saved_order_id, saved_order_body)
          when is_binary(account_id) and is_map(saved_order_body) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)

        TDAmeritrade.Rest.ReplaceSavedOrder.replace_saved_order(
          client,
          account_id,
          saved_order_id,
          saved_order_body
        )
      end

      def replace_saved_order do
        try do
          TDAmeritrade.Rest.ReplaceSavedOrder.replace_saved_order()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
