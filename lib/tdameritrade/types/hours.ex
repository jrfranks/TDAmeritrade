# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.Hours do
  @moduledoc """
  %{
    "Hours" => [
      {"category", [{"type", "string"}]},
      {"date", [{"type", "string"}]},
      {"exchange", [{"type", "string"}]},
      {"isOpen", [{"type", "boolean"}]},
      {"marketType",
        [
          {"enum", [
            "BOND",
            "EQUITY",
            "ETF",
            "FOREX",
            "FUTURE",
            "FUTURE_OPTION",
            "INDEX",
            "INDICATOR",
            "MUTUAL_FUND",
            "OPTION",
            "UNKNOWN" ]
          },
          {"type", "string"}
        ]},
      {"product", [{"type", "string"}]},
      {"productName", [{"type", "string"}]},
      {"sessionHours", [ {"additionalProperties", [{"items", [{"type", "string"}]}, {"type", "array"}]}, {"type", "object"} ]}
    ]
  }
  """

  @typedoc """

  """
  @type t :: map()

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.Hours.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.Hours.is_valid?(x)
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(hours) when map_size(hours) == 0, do: true
  def is_valid?(hours) when is_map(hours), do: true
  def is_valid?(_hours), do: false
end
