# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.Candle do
  @moduledoc """
  %{
    "Candle" => [
      {"close", [{"description", "Close"}, {"format", "double"}, {"type", "number"}]},
      {"datetime", [{"description", "DateTime"}, {"format", "int64"}, {"type", "integer"}]},
      {"high", [{"description", "High"}, {"format", "double"}, {"type", "number"}]},
      {"low", [{"description", "Low"}, {"format", "double"}, {"type", "number"}]},
      {"open", [{"description", "Open"}, {"format", "double"}, {"type", "number"}]},
      {"volume", [{"description", "Volume"}, {"format", "int64"}, {"type", "integer"}]}
    ]
  }
  """

  @typedoc """

  """
  @type t :: map()

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.Candle.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.Candle.is_valid?(x)
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(candle) when map_size(candle) == 0, do: true
  def is_valid?(candle) when is_map(candle), do: true
  def is_valid?(_candle), do: false
end
