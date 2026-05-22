
defmodule TDAmeritrade.Types.TransactionItem do
  @moduledoc """
  %{
    "TransactionItem" => [
      {"properties",
       [
         {"accountId", [{"format", "int32"}, {"type", "integer"}]},
         {"amount", [{"format", "double"}, {"type", "number"}]},
         {"cost", [{"format", "double"}, {"type", "number"}]},
         {"instruction", [{"enum", ["BUY", "SELL"]}, {"type", "string"}]},
         {"instrument", [{"$dict", "TransactionInstrument"}]},
         {"parentChildIndicator", [{"type", "string"}]},
         {"parentOrderKey", [{"format", "int32"}, {"type", "integer"}]},
         {"positionEffect", [{"enum", ["OPENING", "CLOSING", "AUTOMATIC"]}, {"type", "string"}]},
         {"price", [{"format", "double"}, {"type", "number"}]}
       ]},
      {"type", "object"}
    ]
  }
  """

  @typedoc """
  Information about a specific TDAmeritrade transaction.
  """
  @type t :: map()

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.TransactionItem.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.TransactionItem.is_valid?(x)
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(transaction_item) when map_size(transaction_item) == 0, do: true
  def is_valid?(transaction_item) when is_map(transaction_item), do: true
  def is_valid?(_transaction_item), do: false
end
