# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.Mover do
  @moduledoc """
  %{
    "Mover" => [
      {"properties",
       [
         {"change", [{"format", "double"}, {"type", "number"}]},
         {"description", [{"type", "string"}]},
         {"direction", [{"enum", ["up", "down"]}, {"type", "string"}]},
         {"last", [{"format", "double"}, {"type", "number"}]},
         {"symbol", [{"type", "string"}]},
         {"totalVolume", [{"format", "int64"}, {"type", "integer"}]}
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
    iex> TDAmeritrade.Types.Mover.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.Mover.is_valid?(x)
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(mover) when map_size(mover) == 0, do: true
  def is_valid?(mover) when is_map(mover), do: true
  def is_valid?(_mover), do: false
end
