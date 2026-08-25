# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.CandleList do
  @moduledoc """
  %{
    "CandleList" => [
      {"candles", [ {"description", "List of candles"}, {"items", [{"$dict", "Candle"}]}, {"type", "array"} ]},
      {"empty", [{"type", "boolean"}]},
      {"symbol", [{"description", "Symbol"}, {"type", "string"}]}
    ]
  }
  """

  @typedoc """
    List of Candle data
  """
  @type t :: map()

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.CandleList.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.CandleList.is_valid?(x)
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(list) when map_size(list) == 0, do: true
  def is_valid?(list) when is_map(list), do: true
  def is_valid?(_list), do: false
end
