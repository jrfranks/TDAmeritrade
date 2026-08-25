# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.QuoteIndex do
  @moduledoc """
  //Index:
  """

  @typedoc """

  """
  @type t :: %{
          symbol: String.t(),
          description: String.t(),
          lastPrice: float(),
          openPrice: float(),
          highPrice: float(),
          lowPrice: float(),
          closePrice: float(),
          netChange: float(),
          totalVolume: integer(),
          tradeTimeInLong: integer(),
          exchange: String.t(),
          exchangeName: String.t(),
          digits: integer(),
          "52WkHigh": float(),
          "52WkLow": float(),
          securityStatus: String.t()
        }

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.QuoteIndex.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.QuoteIndex.is_valid?("x")
    false
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(price_quote) when map_size(price_quote) == 0, do: true
  def is_valid?(price_quote) when is_map(price_quote), do: true
  def is_valid?(_price_quote), do: false
end
