# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.PlaceOrder do
  @moduledoc """
  Place an order for a specific account.

  Supports the full range of order types via the fluent builders in
  `TDAmeritrade.Orders`.

  ## Example

      order = TDAmeritrade.Orders.Order.market(leg) |> TDAmeritrade.Orders.Order.to_map()
      {:ok, result} = TDAmeritrade.Rest.PlaceOrder.place_order(client, account_id, order)
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec place_order(Client.t() | binary(), String.t(), map()) ::
          {:ok, map()} | {:error, Error.t()}

  def place_order(client_or_user, account_id, order_body)
      when is_binary(account_id) and is_map(order_body) do
    client = TDAmeritrade.Rest.normalize(client_or_user)

    url = "/v1/accounts/#{account_id}/orders"
    body = Poison.encode!(order_body)
    headers = [{"Content-Type", "application/json"}]

    # We need to call the low-level post so we can inspect headers on 201
    case TDAmeritrade.Connection.post(client, url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: resp_body}} ->
        case Poison.decode(resp_body) do
          {:ok, data} -> {:ok, data}
          {:error, err} -> {:error, Error.new_json_error(err)}
        end

      {:ok, %HTTPoison.Response{status_code: 201, headers: resp_headers}} ->
        # TDA returns 201 with Location header containing the new order
        order_id = extract_order_id_from_location(resp_headers)
        {:ok, %{orderId: order_id, status: "CREATED"}}

      {:ok, %HTTPoison.Response{status_code: status, body: resp_body}} ->
        {:error, Error.new(status, resp_body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, Error.new_transport(reason)}

      other ->
        {:error, Error.new_client_error(:unexpected_response, other)}
    end
  end

  def place_order do
    {:error, Error.new_client_error(:missing_account_id_and_order_body)}
  end

  defp extract_order_id_from_location(headers) do
    case List.keyfind(headers, "Location", 0) do
      {"Location", location} ->
        # URL looks like .../orders/123456789
        location |> String.split("/") |> List.last() |> String.to_integer()

      _ ->
        nil
    end
  end

  defmacro __using__(_) do
    quote do
      @deprecated "Use TDAmeritrade.Rest.PlaceOrder.place_order/3 (with a Client) instead"
      def place_order(account_id, order_body) when is_binary(account_id) and is_map(order_body) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.PlaceOrder.place_order(client, account_id, order_body)
      end

      @deprecated "Use TDAmeritrade.Rest.PlaceOrder.place_order/3 instead"
      def place_order do
        try do
          TDAmeritrade.Rest.PlaceOrder.place_order()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
