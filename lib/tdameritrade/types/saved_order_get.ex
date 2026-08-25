# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.SavedOrderGet do
  @moduledoc """
  %{
    "SavedOrderGet" => [
      {"properties",
       [
         {"savedTime", [{"format", "date-time"}, {"type", "string"}]},
         {"activationPrice", [{"format", "double"}, {"type", "number"}]},
         {"orderType",
          [
            {"enum",
             [
               "MARKET",
               "LIMIT",
               "STOP",
               "STOP_LIMIT",
               "TRAILING_STOP",
               "MARKET_ON_CLOSE",
               "EXERCISE",
               "TRAILING_STOP_LIMIT",
               "NET_DEBIT",
               "NET_CREDIT",
               "NET_ZERO"
             ]},
            {"type", "string"}
          ]},
         {"childOrderStrategies",
          [
            {"items", [{"$dict", "OrderGet"}]},
            {"type", "array"},
            {"xml", [{"name", "childOrder"}, {"wrapped", true}]}
          ]},
         {"orderLegCollection",
          [
            {"items", [{"$dict", "OrderLeg"}]},
            {"type", "array"},
            {"xml", [{"name", "orderLeg"}, {"wrapped", true}]}
          ]},
         {"stopPriceLinkType", [{"enum", ["VALUE", "PERCENT", "TICK"]}, {"type", "string"}]},
         {"stopType", [{"enum", ["STANDARD", "BID", "ASK", "LAST", "MARK"]}, {"type", "string"}]},
         {"stopPriceOffset", [{"format", "double"}, {"type", "number"}]},
         {"priceLinkType", [{"enum", ["VALUE", "PERCENT", "TICK"]}, {"type", "string"}]},
         {"orderStrategyType", [{"enum", ["SINGLE", "OCO", "TRIGGER"]}, {"type", "string"}]},
         {"orderId", [{"format", "int64"}, {"type", "integer"}]},
         {"enteredTime", [{"format", "date-time"}, {"type", "string"}]},
         {"priceLinkBasis",
          [
            {"enum",
             ["MANUAL", "BASE", "TRIGGER", "LAST", "BID", "ASK", "ASK_BID", "MARK", "AVERAGE"]},
            {"type", "string"}
          ]},
         {"filledQuantity", [{"format", "double"}, {"type", "number"}]},
         {"price", [{"format", "double"}, {"type", "number"}]},
         {"taxLotMethod",
          [
            {"enum", ["FIFO", "LIFO", "HIGH_COST", "LOW_COST", "AVERAGE_COST", "SPECIFIC_LOT"]},
            {"type", "string"}
          ]},
         {"tag", [{"type", "string"}]},
         {"cancelable", [{"default", false}, {"type", "boolean"}]},
         {"requestedDestination",
          [
            {"enum",
             [
               "INET",
               "ECN_ARCA",
               "CBOE",
               "AMEX",
               "PHLX",
               "ISE",
               "BOX",
               "NYSE",
               "NASDAQ",
               "BATS",
               "C2",
               "AUTO"
             ]},
            {"type", "string"}
          ]},
         {"specialInstruction",
          [
            {"enum", ["ALL_OR_NONE", "DO_NOT_REDUCE", "ALL_OR_NONE_DO_NOT_REDUCE"]},
            {"type", "string"}
          ]},
         {"destinationLinkName", [{"type", "string"}]},
         {"stopPriceLinkBasis",
          [
            {"enum",
             ["MANUAL", "BASE", "TRIGGER", "LAST", "BID", "ASK", "ASK_BID", "MARK", "AVERAGE"]},
            {"type", "string"}
          ]},
         {"remainingQuantity", [{"format", "double"}, {"type", "number"}]},
         {"cancelTime", [{"$dict", "DateParam"}]},
         {"session", [{"enum", ["NORMAL", "AM", "PM", "SEAMLESS"]}, {"type", "string"}]},
         {"stopPrice", [{"format", "double"}, {"type", "number"}]},
         {"statusDescription", [{"type", "string"}]},
         {"complexOrderStrategyType",
          [
            {"enum",
             [
               "NONE",
               "COVERED",
               "VERTICAL",
               "BACK_RATIO",
               "CALENDAR",
               "DIAGONAL",
               "STRADDLE",
               "STRANGLE",
               "COLLAR_SYNTHETIC",
               "BUTTERFLY",
               "CONDOR",
               "IRON_CONDOR",
               "VERTICAL_ROLL",
               "COLLAR_WITH_STOCK",
               "DOUBLE_DIAGONAL",
               "UNBALANCED_BUTTERFLY",
               "UNBALANCED_CONDOR",
               "UNBALANCED_IRON_CONDOR",
               "UNBALANCED_VERTICAL_ROLL",
               "CUSTOM"
             ]},
            {"type", "string"}
          ]},
         {"duration",
          [{"enum", ["DAY", "GOOD_TILL_CANCEL", "FILL_OR_KILL"]}, {"type", "string"}]},
         {"orderActivityCollection",
          [
            {"items", [{"$dict", "OrderActivity"}]},
            {"type", "array"},
            {"xml", [{"name", "orderActivity"}, {"wrapped", true}]}
          ]},
         {"editable", [{"default", false}, {"type", "boolean"}]},
         {"quantity", [{"format", "double"}, {"type", "number"}]},
         {"releaseTime", [{"format", "date-time"}, {"type", "string"}]},
         {"status",
          [
            {"enum",
             [
               "AWAITING_PARENT_ORDER",
               "AWAITING_CONDITION",
               "AWAITING_MANUAL_REVIEW",
               "ACCEPTED",
               "AWAITING_UR_OUT",
               "PENDING_ACTIVATION",
               "QUEUED",
               "WORKING",
               "REJECTED",
               "PENDING_CANCEL",
               "CANCELED",
               "PENDING_REPLACE",
               "REPLACED",
               "FILLED",
               "EXPIRED"
             ]},
            {"type", "string"}
          ]},
         {"savedOrderId", [{"format", "int64"}, {"type", "integer"}]},
         {"replacingOrderCollection",
          [
            {"items", [{"$dict", "OrderGet"}]},
            {"type", "array"},
            {"xml", [{"name", "replacingOrder"}, {"wrapped", true}]}
          ]},
         {"closeTime", [{"format", "date-time"}, {"type", "string"}]},
         {"accountId", [{"format", "int64"}, {"type", "integer"}]}
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
    iex> TDAmeritrade.Types.SavedOrderGet.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.SavedOrderGet.is_valid?(x)
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(order) when map_size(order) == 0, do: true
  def is_valid?(order) when is_map(order), do: true
  def is_valid?(_order), do: false
end
