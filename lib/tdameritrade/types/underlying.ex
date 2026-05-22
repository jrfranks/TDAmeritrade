
defmodule TDAmeritrade.Types.Underlying do
  @moduledoc """
  %{
    "Underlying" => [
      {"properties",
       [
         {"ask", [{"format", "double"}, {"type", "number"}]},
         {"askSize", [{"format", "int32"}, {"type", "integer"}]},
         {"bid", [{"format", "double"}, {"type", "number"}]},
         {"bidSize", [{"format", "int32"}, {"type", "integer"}]},
         {"change", [{"format", "double"}, {"type", "number"}]},
         {"close", [{"format", "double"}, {"type", "number"}]},
         {"delayed", [{"type", "boolean"}]},
         {"description", [{"type", "string"}]},
         {"exchangeName",
          [
            {"enum", ["IND", "ASE", "NYS", "NAS", "NAP", "PAC", "OPR", "BATS"]},
            {"type", "string"}
          ]},
         {"fiftyTwoWeekHigh", [{"format", "double"}, {"type", "number"}]},
         {"fiftyTwoWeekLow", [{"format", "double"}, {"type", "number"}]},
         {"highPrice", [{"format", "double"}, {"type", "number"}]},
         {"last", [{"format", "double"}, {"type", "number"}]},
         {"lowPrice", [{"format", "double"}, {"type", "number"}]},
         {"mark", [{"format", "double"}, {"type", "number"}]},
         {"markChange", [{"format", "double"}, {"type", "number"}]},
         {"markPercentChange", [{"format", "double"}, {"type", "number"}]},
         {"openPrice", [{"format", "double"}, {"type", "number"}]},
         {"percentChange", [{"format", "double"}, {"type", "number"}]},
         {"quoteTime", [{"format", "int64"}, {"type", "integer"}]},
         {"symbol", [{"type", "string"}]},
         {"totalVolume", [{"format", "int64"}, {"type", "integer"}]},
         {"tradeTime", [{"format", "int64"}, {"type", "integer"}]}
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
    iex> TDAmeritrade.Types.Underlying.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.Underlying.is_valid?(x)
    true
  """
  def is_valid?(underlying) when map_size(underlying) == 0, do: true
  def is_valid?(underlying) when is_map(underlying), do: true
  def is_valid?(_user_principal), do: false
end
