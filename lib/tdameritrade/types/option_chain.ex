# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.OptionChain do
  @moduledoc """
  %{
    "OptionChain" => [
      {"properties",
       [
         {"callExpDateMap", [{"additionalProperties", [{"type", "object"}]}, {"type", "object"}]},
         {"daysToExpiration", [{"format", "double"}, {"type", "number"}]},
         {"interestRate", [{"format", "double"}, {"type", "number"}]},
         {"interval", [{"format", "double"}, {"type", "number"}]},
         {"isDelayed", [{"type", "boolean"}]},
         {"isIndex", [{"type", "boolean"}]},
         {"putExpDateMap", [{"additionalProperties", [{"type", "object"}]}, {"type", "object"}]},
         {"status", [{"type", "string"}]},
         {"strategy",
          [
            {"enum",
             [
               "SINGLE",
               "ANALYTICAL",
               "COVERED",
               "VERTICAL",
               "CALENDAR",
               "STRANGLE",
               "STRADDLE",
               "BUTTERFLY",
               "CONDOR",
               "DIAGONAL",
               "COLLAR",
               "ROLL"
             ]},
            {"type", "string"}
          ]},
         {"symbol", [{"type", "string"}]},
         {"underlying", [{"$dict", "Underlying"}]},
         {"underlyingPrice", [{"format", "double"}, {"type", "number"}]},
         {"volatility", [{"format", "double"}, {"type", "number"}]}
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
    iex> TDAmeritrade.Types.OptionChain.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.OptionChain.is_valid?(x)
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(option_chain) when map_size(option_chain) == 0, do: true
  def is_valid?(option_chain) when is_map(option_chain), do: true
  def is_valid?(_option_chain), do: false
end
