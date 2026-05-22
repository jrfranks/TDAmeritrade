# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.GetQuotes do
  @moduledoc """
  Get quotes for one or more symbols in a single request.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_quotes(Client.t() | binary(), String.t()) :: {:ok, map()} | {:error, Error.t()}

  def get_quotes(client_or_user, symbols) when is_binary(symbols) do
    url = "/v1/marketdata/quotes?symbol=#{URI.encode_www_form(symbols)}"
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_quotes do
    {:error, Error.new_client_error(:missing_symbols_and_client)}
  end

  defmacro __using__(_) do
    quote do
      def get_quotes(symbols) when is_binary(symbols) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.GetQuotes.get_quotes(client, symbols)
      end

      def get_quotes do
        try do
          TDAmeritrade.Rest.GetQuotes.get_quotes()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
