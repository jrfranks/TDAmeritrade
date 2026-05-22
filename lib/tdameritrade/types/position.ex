
defmodule TDAmeritrade.Types.Position do
  @moduledoc """
  %{
    "Position" => [
      {"properties",
       [
         {"agedQuantity", [{"format", "double"}, {"type", "number"}]},
         {"averagePrice", [{"format", "double"}, {"type", "number"}]},
         {"currentDayProfitLoss", [{"format", "double"}, {"type", "number"}]},
         {"currentDayProfitLossPercentage", [{"format", "double"}, {"type", "number"}]},
         {"instrument", [{"$dict", "Instrument"}]},
         {"longQuantity", [{"format", "double"}, {"type", "number"}]},
         {"marketValue", [{"format", "double"}, {"type", "number"}]},
         {"settledLongQuantity", [{"format", "double"}, {"type", "number"}]},
         {"settledShortQuantity", [{"format", "double"}, {"type", "number"}]},
         {"shortQuantity", [{"format", "double"}, {"type", "number"}]}
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
    iex> TDAmeritrade.Types.Position.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.Position.is_valid?(x)
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(position) when map_size(position) == 0, do: true
  def is_valid?(position) when is_map(position), do: true
  def is_valid?(_position), do: false
end
