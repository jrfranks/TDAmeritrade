
defmodule TDAmeritrade.Types.Instrument do
  @typedoc """
  %{
    "Instrument" => [
      {"discriminator", "assetType"},
      {"properties",
       [
         {"assetType",
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
         {"cusip", [{"type", "string"}]},
         {"description", [{"type", "string"}]},
         {"symbol", [{"type", "string"}]}
       ]},
      {"type", "object"}
    ]
  }

  %{
    "Instrument" => [
      {"discriminator", "assetType"},
      {"properties",
       [
         {"assetType",
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
         {"cusip", [{"type", "string"}]},
         {"description", [{"type", "string"}]},
         {"symbol", [{"type", "string"}]}
       ]},
      {"type", "object"}
    ],
    "OrderActivity" => [
      {"discriminator", "activityType"},
      {"properties",
       [{"activityType", [{"enum", ["EXECUTION", "ORDER_ACTION"]}, {"type", "string"}]}]},
      {"type", "object"}
    ]
  }

  %{
    "Instrument" => [
      {"properties",
       [
         {"assetType",
          [
            {"enum", ["EQUITY", "OPTION", "MUTUAL_FUND", "FIXED_INCOME", "INDEX"]},
            {"type", "string"}
          ]},
         {"description", [{"type", "string"}]},
         {"symbol", [{"type", "string"}]}
       ]},
      {"type", "object"}
    ]
  }

  %{
    "Instrument" => [
      {"properties",
       [
         {"assetType",
          [
            {"enum", ["EQUITY", "OPTION", "MUTUAL_FUND", "FIXED_INCOME", "INDEX"]},
            {"type", "string"}
          ]},
         {"description", [{"type", "string"}]},
         {"symbol", [{"type", "string"}]}
       ]},
      {"type", "object"}
    ]
  }
  """

  @type t :: %{
          symbol: String.t(),
          description: String.t(),
          assetType: AssetType.t()
        }

  @spec is_valid?(t) :: boolean()
  def is_valid?(instrument) when is_map(instrument) do
    TDAmeritrade.Types.Symbol.is_valid?(instrument.symbol) &&
      TDAmeritrade.Types.Description.is_valid?(instrument.description) &&
      TDAmeritrade.Types.AssetType.is_valid?(instrument.assetType)
  end

  def is_valid?(_item), do: false
end
