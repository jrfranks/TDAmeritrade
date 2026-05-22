# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.GetHoursForASingleMarket do
  @moduledoc """
  Get market hours for a single market.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_hours_for_a_single_market(Client.t() | binary(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}

  def get_hours_for_a_single_market(client_or_user, market, opts \\ []) when is_binary(market) do
    query =
      opts
      |> Enum.map(fn {k, v} -> "#{k}=#{URI.encode_www_form(to_string(v))}" end)
      |> Enum.join("&")

    url = "/v1/marketdata/#{market}/hours" <> if query == "", do: "", else: "?" <> query
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_hours_for_a_single_market do
    {:error, Error.new_client_error(:missing_market_and_client)}
  end

  defmacro __using__(_) do
    quote do
      def get_hours_for_a_single_market(market, opts \\ []) when is_binary(market) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)

        TDAmeritrade.Rest.GetHoursForASingleMarket.get_hours_for_a_single_market(
          client,
          market,
          opts
        )
      end

      def get_hours_for_a_single_market do
        try do
          TDAmeritrade.Rest.GetHoursForASingleMarket.get_hours_for_a_single_market()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
