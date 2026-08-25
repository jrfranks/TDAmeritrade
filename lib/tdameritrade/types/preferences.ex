# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.Preferences do
  @moduledoc """
  %{
    "Preferences" => [
      {"properties",
       [
         {"authTokenTimeout",
          [
            {"enum", ["FIFTY_FIVE_MINUTES", "TWO_HOURS", "FOUR_HOURS", "EIGHT_HOURS"]},
            {"type", "string"}
          ]},
         {"defaultAdvancedToolLaunch",
          [{"enum", ["TA", "N", "Y", "TOS", "NONE", "CC2"]}, {"type", "string"}]},
         {"defaultEquityOrderDuration",
          [{"enum", ["DAY", "GOOD_TILL_CANCEL", "NONE"]}, {"type", "string"}]},
         {"defaultEquityOrderLegInstruction",
          [{"enum", ["BUY", "SELL", "BUY_TO_COVER", "SELL_SHORT", "NONE"]}, {"type", "string"}]},
         {"defaultEquityOrderMarketSession",
          [{"enum", ["AM", "PM", "NORMAL", "SEAMLESS", "NONE"]}, {"type", "string"}]},
         {"defaultEquityOrderPriceLinkType",
          [{"enum", ["VALUE", "PERCENT", "NONE"]}, {"type", "string"}]},
         {"defaultEquityOrderType",
          [
            {"enum",
             ["MARKET", "LIMIT", "STOP", "STOP_LIMIT", "TRAILING_STOP", "MARKET_ON_CLOSE", "NONE"]},
            {"type", "string"}
          ]},
         {"defaultEquityQuantity", [{"format", "int32"}, {"minimum", 0.0}, {"type", "integer"}]},
         {"directEquityRouting", [{"default", false}, {"type", "boolean"}]},
         {"directOptionsRouting", [{"default", false}, {"type", "boolean"}]},
         {"equityTaxLotMethod",
          [
            {"enum",
             ["FIFO", "LIFO", "HIGH_COST", "LOW_COST", "MINIMUM_TAX", "AVERAGE_COST", "NONE"]},
            {"type", "string"}
          ]},
         {"expressTrading", [{"default", false}, {"type", "boolean"}]},
         {"mutualFundTaxLotMethod",
          [
            {"enum",
             ["FIFO", "LIFO", "HIGH_COST", "LOW_COST", "MINIMUM_TAX", "AVERAGE_COST", "NONE"]},
            {"type", "string"}
          ]},
         {"optionTaxLotMethod",
          [
            {"enum",
             ["FIFO", "LIFO", "HIGH_COST", "LOW_COST", "MINIMUM_TAX", "AVERAGE_COST", "NONE"]},
            {"type", "string"}
          ]}
       ]},
      {"required",
       [
         "authTokenTimeout",
         "defaultAdvancedToolLaunch",
         "defaultEquityOrderDuration",
         "defaultEquityOrderLegInstruction",
         "defaultEquityOrderMarketSession",
         "defaultEquityOrderPriceLinkType",
         "defaultEquityOrderType",
         "defaultEquityQuantity",
         "equityTaxLotMethod",
         "expressTrading",
         "mutualFundTaxLotMethod",
         "optionTaxLotMethod"
       ]},
      {"type", "object"}
    ]
  }
  """

  @typedoc """

  """
  @type t :: map()

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.Preferences.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.Preferences.is_valid?(x)
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(preference) when map_size(preference) == 0, do: true
  def is_valid?(preference) when is_map(preference), do: true
  def is_valid?(_preference), do: false
end
