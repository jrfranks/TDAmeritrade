# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Rest.GetOrdersByQuery do
  @moduledoc """
  Query orders across accounts using flexible filters (status, date range, etc.).
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_orders_by_query(Client.t() | binary(), keyword()) ::
          {:ok, list(map())} | {:error, Error.t()}

  def get_orders_by_query(client_or_user, opts \\ []) do
    query =
      opts
      |> Enum.map(fn {k, v} -> "#{k}=#{URI.encode_www_form(to_string(v))}" end)
      |> Enum.join("&")

    url = "/v1/orders" <> if query == "", do: "", else: "?" <> query
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_orders_by_query do
    {:error, Error.new_client_error(:missing_client)}
  end

  defmacro __using__(_) do
    quote do
      def get_orders_by_query(opts \\ []) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.GetOrdersByQuery.get_orders_by_query(client, opts)
      end
    end
  end
end
