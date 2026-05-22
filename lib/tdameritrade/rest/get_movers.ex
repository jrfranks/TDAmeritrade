# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.GetMovers do
  @moduledoc """
  Get the top movers (gainers/losers) for a specific index or market.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_movers(Client.t() | binary(), String.t(), keyword()) ::
          {:ok, list(map())} | {:error, Error.t()}

  def get_movers(client_or_user, index, opts \\ []) when is_binary(index) do
    query =
      opts
      |> Enum.map(fn {k, v} -> "#{k}=#{URI.encode_www_form(to_string(v))}" end)
      |> Enum.join("&")

    url = "/v1/marketdata/#{index}/movers" <> if query == "", do: "", else: "?" <> query
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_movers do
    {:error, Error.new_client_error(:missing_index_and_client)}
  end

  defmacro __using__(_) do
    quote do
      def get_movers(index, opts \\ []) when is_binary(index) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.GetMovers.get_movers(client, index, opts)
      end

      def get_movers do
        try do
          TDAmeritrade.Rest.GetMovers.get_movers()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
