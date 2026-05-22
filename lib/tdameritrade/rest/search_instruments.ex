# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.SearchInstruments do
  @moduledoc """
  Search for instruments by symbol or description.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec search_instruments(Client.t() | binary(), String.t(), keyword()) ::
          {:ok, list(map())} | {:error, Error.t()}

  def search_instruments(client_or_user, symbol, opts \\ []) when is_binary(symbol) do
    base_query = "symbol=#{URI.encode_www_form(symbol)}"

    extra =
      opts
      |> Enum.map(fn {k, v} -> "#{k}=#{URI.encode_www_form(to_string(v))}" end)
      |> Enum.join("&")

    query = if extra == "", do: base_query, else: base_query <> "&" <> extra

    url = "/v1/instruments?" <> query
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def search_instruments do
    {:error, Error.new_client_error(:missing_symbol_and_client)}
  end

  defmacro __using__(_) do
    quote do
      def search_instruments(symbol, opts \\ []) when is_binary(symbol) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.SearchInstruments.search_instruments(client, symbol, opts)
      end

      def search_instruments do
        try do
          TDAmeritrade.Rest.SearchInstruments.search_instruments()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
