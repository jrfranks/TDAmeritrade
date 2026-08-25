# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Rest.GetQuote do
  @moduledoc """
  Get a single quote for a symbol.

  Part of the modern `TDAmeritrade.Rest.*` surface. Prefer this over the
  legacy `TDAmeritrade.get_quote/1` when writing new code.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @doc """
  Fetches a delayed or real-time quote for the given symbol.

  ## Examples

      client = TDAmeritrade.Client.new(access_token: token)
      {:ok, data} = TDAmeritrade.Rest.GetQuote.get_quote(client, "AAPL")
      # data => %{"AAPL" => %{"bidPrice" => ..., ...}}

  The first argument can also be a legacy binary user key for backward
  compatibility with the old flat API.
  """
  @spec get_quote(Client.t() | binary(), String.t()) :: {:ok, map()} | {:error, Error.t()}

  def get_quote(client_or_user, symbol) when is_binary(symbol) do
    url = "/v1/marketdata/#{symbol}/quotes"
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_quote do
    {:error, Error.new_client_error(:missing_symbol_and_client)}
  end

  defmacro __using__(_) do
    quote do
      @deprecated "Use TDAmeritrade.Rest.GetQuote.get_quote/2 (with a Client) instead"
      def get_quote(symbol) when is_binary(symbol) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.GetQuote.get_quote(client, symbol)
      end

      @deprecated "Use TDAmeritrade.Rest.GetQuote.get_quote/2 instead"
      def get_quote do
        try do
          TDAmeritrade.Rest.GetQuote.get_quote()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
