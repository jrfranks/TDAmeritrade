# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Rest.GetOptionChain do
  @moduledoc """
  Retrieve the full option chain for a symbol.

  Works well with the `TDAmeritrade.OptionChain` builder for constructing
  complex queries (strike count, contract type, etc.).
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_option_chain(Client.t() | binary(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}

  def get_option_chain(client_or_user, symbol, opts \\ []) when is_binary(symbol) do
    base_query = "symbol=#{URI.encode_www_form(symbol)}"

    extra =
      opts
      |> Enum.map(fn {k, v} -> "#{k}=#{URI.encode_www_form(to_string(v))}" end)
      |> Enum.join("&")

    query = if extra == "", do: base_query, else: base_query <> "&" <> extra

    url = "/v1/marketdata/chains?" <> query
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_option_chain do
    {:error, Error.new_client_error(:missing_symbol_and_client)}
  end

  defmacro __using__(_) do
    quote do
      def get_option_chain(symbol, opts \\ []) when is_binary(symbol) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.GetOptionChain.get_option_chain(client, symbol, opts)
      end

      def get_option_chain do
        try do
          TDAmeritrade.Rest.GetOptionChain.get_option_chain()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
