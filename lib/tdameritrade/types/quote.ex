# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.Quote do
  @moduledoc """
    This module defines instrument quote data structures
  """

  @typedoc """
  Instrument quote data
  """

  # (No sub-requires needed after cleanup)

  @type t :: %{
          Properties: %{
            isAmexDelayed: boolean(),
            isCmeDelayed: boolean(),
            isForexDelayed: boolean(),
            isIceDelayed: boolean(),
            isNasdaqDelayed: boolean(),
            isNyseDelayed: boolean(),
            isOpraDelayed: boolean()
          },
          "Mutual Fund": TDAmeritrade.Types.QuoteMutualFund.t(),
          Future: TDAmeritrade.Types.QuoteFuture.t(),
          "Future Options": TDAmeritrade.Types.QuoteFutureOptions.t(),
          Index: TDAmeritrade.Types.QuoteIndex.t(),
          Option: TDAmeritrade.Types.QuoteOption.t(),
          Forex: TDAmeritrade.Types.QuoteForex.t(),
          ETF: TDAmeritrade.Types.QuoteETF.t(),
          Equity: TDAmeritrade.Types.QuoteEquity.t()
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
