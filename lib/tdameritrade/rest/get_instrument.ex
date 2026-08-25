# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Rest.GetInstrument do
  @moduledoc """
  Look up instrument details by CUSIP.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_instrument(Client.t() | binary(), String.t()) :: {:ok, map()} | {:error, Error.t()}

  def get_instrument(client_or_user, cusip) when is_binary(cusip) do
    url = "/v1/instruments/#{cusip}"
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_instrument do
    {:error, Error.new_client_error(:missing_cusip_and_client)}
  end

  defmacro __using__(_) do
    quote do
      def get_instrument(cusip) when is_binary(cusip) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.GetInstrument.get_instrument(client, cusip)
      end

      def get_instrument do
        try do
          TDAmeritrade.Rest.GetInstrument.get_instrument()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
