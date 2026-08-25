# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.OrderLeg do
  @moduledoc """
  %{
    "OrderLeg" => [
      {"properties",
       [
         {"instruction",
          [
            {"enum",
             [
               "BUY",
               "SELL",
               "BUY_TO_COVER",
               "SELL_SHORT",
               "BUY_TO_OPEN",
               "BUY_TO_CLOSE",
               "SELL_TO_OPEN",
               "SELL_TO_CLOSE",
               "EXCHANGE"
             ]},
            {"type", "string"}
          ]},
         {"instrument", [{"$dict", "Instrument"}]},
         {"legId", [{"format", "int64"}, {"type", "integer"}]},
         {"orderLegType",
          [
            {"enum",
             [
               "EQUITY",
               "OPTION",
               "INDEX",
               "MUTUAL_FUND",
               "CASH_EQUIVALENT",
               "FIXED_INCOME",
               "CURRENCY"
             ]},
            {"type", "string"}
          ]},
         {"positionEffect", [{"enum", ["OPENING", "CLOSING", "AUTOMATIC"]}, {"type", "string"}]},
         {"quantity", [{"format", "double"}, {"type", "number"}]},
         {"quantityType", [{"enum", ["ALL_SHARES", "DOLLARS", "SHARES"]}, {"type", "string"}]}
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
    iex> TDAmeritrade.Types.OrderLeg.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.OrderLeg.is_valid?(x)
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(leg) when map_size(leg) == 0, do: true
  def is_valid?(leg) when is_map(leg), do: true
  def is_valid?(_leg), do: false
end
