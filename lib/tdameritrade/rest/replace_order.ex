# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.ReplaceOrder do
  @moduledoc """
  Replace an existing order with a new definition.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec replace_order(Client.t() | binary(), String.t(), String.t() | integer(), map()) ::
          {:ok, map()} | {:error, Error.t()}

  # Support default (no default needed here, but for consistency with other functions)
  def replace_order(client_or_user, account_id, order_id, replacement_order)

  def replace_order(_client_or_user, _account_id, _order_id, nil) do
    {:error, Error.new_client_error(:invalid_replacement_body, "replacement body cannot be nil")}
  end

  def replace_order(client_or_user, account_id, order_id, replacement_order)
      when is_binary(account_id) and is_map(replacement_order) do
    client = TDAmeritrade.Rest.normalize(client_or_user)
    order_id_str = to_string(order_id)

    url = "/v1/accounts/#{account_id}/orders/#{order_id_str}"
    body = Poison.encode!(replacement_order)
    headers = [{"Content-Type", "application/json"}]

    case TDAmeritrade.Connection.put(client, url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: resp_body}} ->
        case Poison.decode(resp_body) do
          {:ok, data} -> {:ok, data}
          {:error, err} -> {:error, Error.new_json_error(err)}
        end

      {:ok, %HTTPoison.Response{status_code: 201, headers: resp_headers}} ->
        new_order_id = extract_order_id_from_location(resp_headers)
        {:ok, %{orderId: new_order_id, replacedOrderId: order_id, status: "REPLACED"}}

      {:ok, %HTTPoison.Response{status_code: status, body: resp_body}} ->
        {:error, Error.new(status, resp_body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, Error.new_transport(reason)}

      other ->
        {:error, Error.new_client_error(:unexpected_response, other)}
    end
  end

  def replace_order do
    {:error, Error.new_client_error(:missing_account_order_id_and_body)}
  end

  defp extract_order_id_from_location(headers) do
    case List.keyfind(headers, "Location", 0) do
      {"Location", location} ->
        location |> String.split("/") |> List.last() |> String.to_integer()

      _ ->
        nil
    end
  end

  defmacro __using__(_) do
    quote do
      # Declare the default argument once for multiple clauses
      def replace_order(account_id, order_id, replacement_order \\ nil)

      def replace_order(_account_id, _order_id, nil) do
        {:error, Error.new_client_error(:invalid_replacement_body, "replacement body cannot be nil")}
      end

      def replace_order(account_id, order_id, replacement_order)
          when is_binary(account_id) and is_map(replacement_order) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)

        TDAmeritrade.Rest.ReplaceOrder.replace_order(
          client,
          account_id,
          order_id,
          replacement_order
        )
      end

      def replace_order do
        try do
          TDAmeritrade.Rest.ReplaceOrder.replace_order()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
