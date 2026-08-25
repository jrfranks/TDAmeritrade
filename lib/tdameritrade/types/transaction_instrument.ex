# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.TransactionInstrument do
  @moduledoc """
  %{
    "TransactionInstrument" => [
      {"properties",
       [
         {"assetType",
          [
            {"enum", ["EQUITY", "MUTUAL_FUND", "OPTION", "FIXED_INCOME", "CASH_EQUIVALENT"]},
            {"type", "string"}
          ]},
         {"bondInterestRate", [{"format", "double"}, {"type", "number"}]},
         {"bondMaturityDate", [{"format", "date-time"}, {"type", "string"}]},
         {"cusip", [{"type", "string"}]},
         {"description", [{"type", "string"}]},
         {"optionExpirationDate", [{"format", "date-time"}, {"type", "string"}]},
         {"optionStrikePrice", [{"format", "double"}, {"type", "number"}]},
         {"putCall", [{"enum", ["PUT", "CALL"]}, {"type", "string"}]},
         {"symbol", [{"type", "string"}]},
         {"underlyingSymbol", [{"type", "string"}]}
       ]},
      {"type", "object"}
    ]
  }
  """

  @typedoc """

  """
  @type t :: binary() | String.t()

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.TransactionInstrument.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.TransactionInstrument.is_valid?(x)
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(instrument) when map_size(instrument) == 0, do: true
  def is_valid?(instrument) when is_map(instrument), do: true
  def is_valid?(_instrument), do: false
end
