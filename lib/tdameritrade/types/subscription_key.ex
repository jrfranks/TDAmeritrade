
defmodule TDAmeritrade.Types.SubscriptionKey do
  @moduledoc """
  %{
    "SubscriptionKey" => [
      {"properties", [{"keys", [{"items", [{"$dict", "Key"}]}, {"type", "array"}]}]},
      {"type", "object"}
    ]
  }
  """

  @typedoc """

  """
  @type t :: binary() | String.t()

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.SubscriptionKey.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.SubscriptionKey.is_valid?(x)
    true
  """
  def is_valid?(underlying) when map_size(underlying) == 0, do: true
  def is_valid?(underlying) when is_map(underlying), do: true
  def is_valid?(_underlying), do: false
end
