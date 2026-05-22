
defmodule TDAmeritrade.Types.QuoteOption do
  @moduledoc """
  //Option:
  """

  @typedoc """

  """
  @type t :: %{
          symbol: String.t(),
          description: String.t(),
          bidPrice: float(),
          bidSize: integer(),
          askPrice: float(),
          askSize: integer(),
          lastPrice: float(),
          lastSize: integer(),
          openPrice: float(),
          highPrice: float(),
          lowPrice: float(),
          closePrice: float(),
          netChange: float(),
          totalVolume: integer(),
          quoteTimeInLong: integer(),
          tradeTimeInLong: integer(),
          mark: float(),
          openInterest: float(),
          volatility: float(),
          moneyIntrinsicValue: float(),
          multiplier: float(),
          strikePrice: float(),
          contractType: String.t(),
          underlying: String.t(),
          timeValue: float(),
          deliverables: String.t(),
          delta: float(),
          gamma: float(),
          theta: float(),
          vega: float(),
          rho: float(),
          securityStatus: String.t(),
          theoreticalOptionValue: float(),
          underlyingPrice: float(),
          uvExpirationType: String.t(),
          exchange: String.t(),
          exchangeName: String.t(),
          settlementType: String.t()
        }

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.QuoteOption.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.QuoteOption.is_valid?("x")
    false
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(price_quote) when map_size(price_quote) == 0, do: true
  def is_valid?(price_quote) when is_map(price_quote), do: true
  def is_valid?(_price_quote), do: false
end
