# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.QuoteEquity do
  @moduledoc """
  """

  @typedoc """

  """
  @type t :: %{
          symbol: String.t(),
          description: String.t(),
          bidPrice: float(),
          bidSize: integer(),
          bidId: String.t(),
          askPrice: float(),
          askSize: integer(),
          askId: String.t(),
          lastPrice: float(),
          lastSize: integer(),
          lastId: String.t(),
          openPrice: float(),
          highPrice: float(),
          lowPrice: float(),
          closePrice: float(),
          netChange: float(),
          totalVolume: integer(),
          quoteTimeInLong: integer(),
          tradeTimeInLong: integer(),
          mark: float(),
          exchange: String.t(),
          exchangeName: String.t(),
          marginable: boolean(),
          shortable: boolean(),
          volatility: float(),
          digits: integer(),
          "52WkHigh": float(),
          "52WkLow": float(),
          peRatio: float(),
          divAmount: float(),
          divYield: float(),
          divDate: String.t(),
          securityStatus: String.t(),
          regularMarketLastPrice: float(),
          regularMarketLastSize: integer(),
          regularMarketNetChange: float(),
          regularMarketTradeTimeInLong: integer()
        }

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.QuoteEquity.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.QuoteEquity.is_valid?("x")
    false
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(price_quote) when map_size(price_quote) == 0, do: true
  def is_valid?(price_quote) when is_map(price_quote), do: true
  def is_valid?(_price_quote), do: false
end
