# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.GetHoursForMultipleMarkets do
  @moduledoc """
  Get market hours for multiple markets in one call.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_hours_for_multiple_markets(Client.t() | binary(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}

  def get_hours_for_multiple_markets(client_or_user, opts \\ []) do
    query =
      opts
      |> Enum.map(fn {k, v} -> "#{k}=#{URI.encode_www_form(to_string(v))}" end)
      |> Enum.join("&")

    url = "/v1/marketdata/hours" <> if query == "", do: "", else: "?" <> query
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_hours_for_multiple_markets do
    {:error, Error.new_client_error(:missing_client)}
  end

  defmacro __using__(_) do
    quote do
      def get_hours_for_multiple_markets(opts \\ []) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.GetHoursForMultipleMarkets.get_hours_for_multiple_markets(client, opts)
      end
    end
  end
end
