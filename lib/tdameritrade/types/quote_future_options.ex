
defmodule TDAmeritrade.Types.QuoteFutureOptions do
  @moduledoc """

  //Future Options:
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
          description: String.t(),
          openPriceInDouble: float(),
          netChangeInDouble: float(),
          openInterest: float(),
          exchangeName: String.t(),
          securityStatus: String.t(),
          volatility: float(),
          moneyIntrinsicValueInDouble: float(),
          multiplierInDouble: float(),
          digits: integer(),
          strikePriceInDouble: float(),
          contractType: String.t(),
          underlying: String.t(),
          timeValueInDouble: float(),
          deltaInDouble: float(),
          gammaInDouble: float(),
          thetaInDouble: float(),
          vegaInDouble: float(),
          rhoInDouble: float(),
          mark: float(),
          tick: float(),
          tickAmount: float(),
          futureIsTradable: boolean(),
          futureTradingHours: String.t(),
          futurePercentChange: float(),
          futureIsActive: boolean(),
          futureExpirationDate: integer(),
          expirationType: String.t(),
          exerciseType: String.t(),
          inTheMoney: boolean()
        }

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.QuoteFutureOptions.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.QuoteFutureOptions.is_valid?("x")
    false
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(price_quote) when map_size(price_quote) == 0, do: true
  def is_valid?(price_quote) when is_map(price_quote), do: true
  def is_valid?(_price_quote), do: false
end
