# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.GetPriceHistory do
  @moduledoc """
  Retrieve historical price candles for a symbol.

  Supports the usual period/frequency parameters via options.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_price_history(Client.t() | binary(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}

  def get_price_history(client_or_user, symbol, opts \\ []) when is_binary(symbol) do
    query =
      opts
      |> Enum.map(fn {k, v} -> "#{k}=#{URI.encode_www_form(to_string(v))}" end)
      |> Enum.join("&")

    url = "/v1/marketdata/#{symbol}/pricehistory" <> if query == "", do: "", else: "?" <> query
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_price_history do
    {:error, Error.new_client_error(:missing_symbol_and_client)}
  end

  defmacro __using__(_) do
    quote do
      def get_price_history(symbol, opts \\ []) when is_binary(symbol) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.GetPriceHistory.get_price_history(client, symbol, opts)
      end

      def get_price_history do
        try do
          TDAmeritrade.Rest.GetPriceHistory.get_price_history()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
