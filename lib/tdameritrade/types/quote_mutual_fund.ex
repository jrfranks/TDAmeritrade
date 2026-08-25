# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.QuoteMutualFund do
  @moduledoc """
  //Mutual Fund:
  """

  @typedoc """

  """
  @type t :: %{
          symbol: String.t(),
          description: String.t(),
          closePrice: float(),
          netChange: float(),
          totalVolume: integer(),
          tradeTimeInLong: integer(),
          exchange: String.t(),
          exchangeName: String.t(),
          digits: integer(),
          "52WkHigh": float(),
          "52WkLow": float(),
          nAV: float(),
          peRatio: float(),
          divAmount: float(),
          divYield: float(),
          divDate: String.t(),
          securityStatus: String.t()
        }

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.Quote.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.Quote.is_valid?(x)
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(price_quote) when map_size(price_quote) == 0, do: true
  def is_valid?(price_quote) when is_map(price_quote), do: true
  def is_valid?(_price_quote), do: false
end
