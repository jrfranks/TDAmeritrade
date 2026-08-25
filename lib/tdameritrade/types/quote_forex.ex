# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.QuoteForex do
  @moduledoc """
  """

  @typedoc """

  """
  @type t :: %{
          symbol: String.t(),
          bidPriceInDouble: float(),
          askPriceInDouble: float(),
          lastPriceInDouble: float(),
          highPriceInDouble: float(),
          lowPriceInDouble: float(),
          closePriceInDouble: float(),
          exchange: String.t(),
          description: String.t(),
          openPriceInDouble: float(),
          changeInDouble: float(),
          percentChange: float(),
          exchangeName: String.t(),
          digits: integer(),
          securityStatus: String.t(),
          tick: float(),
          tickAmount: float(),
          product: String.t(),
          tradingHours: String.t(),
          isTradable: boolean(),
          marketMaker: String.t(),
          "52WkHighInDouble": float(),
          "52WkLowInDouble": float(),
          mark: float()
        }

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.QuoteForex.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.QuoteForex.is_valid?("x")
    false
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(price_quote) when map_size(price_quote) == 0, do: true
  def is_valid?(price_quote) when is_map(price_quote), do: true
  def is_valid?(_price_quote), do: false
end
