
defmodule TDAmeritrade.Types.QuoteFuture do
  @moduledoc """
  //Future:
  """

  @typedoc """

  """
  @type t :: %{
          symbol: String.t(),
          bidPriceInDouble: float(),
          askPriceInDouble: float(),
          lastPriceInDouble: float(),
          bidId: String.t(),
          askId: String.t(),
          highPriceInDouble: float(),
          lowPriceInDouble: float(),
          closePriceInDouble: float(),
          exchange: String.t(),
          description: String.t(),
          lastId: String.t(),
          openPriceInDouble: float(),
          changeInDouble: float(),
          futurePercentChange: float(),
          exchangeName: String.t(),
          securityStatus: String.t(),
          openInterest: float(),
          mark: float(),
          tick: float(),
          tickAmount: float(),
          product: String.t(),
          futurePriceFormat: String.t(),
          futureTradingHours: String.t(),
          futureIsTradable: boolean(),
          futureMultiplier: float(),
          futureIsActive: boolean(),
          futureSettlementPrice: float(),
          futureActiveSymbol: String.t(),
          futureExpirationDate: String.t()
        }

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.QuoteFuture.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.QuoteFuture.is_valid?("x")
    false
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(price_quote) when map_size(price_quote) == 0, do: true
  def is_valid?(price_quote) when is_map(price_quote), do: true
  def is_valid?(_price_quote), do: false
end
