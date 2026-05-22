
defmodule TDAmeritrade.Types.Key do
  @moduledoc """
  %{"Key" => [{"properties", [{"key", [{"type", "string"}]}]}, {"type", "object"}]}
  """

  @typedoc """
  %{"Key" => [{"properties", [{"key", [{"type", "string"}]}]}, {"type", "object"}]}
  """
  @type t :: binary() | String.t()

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.Key.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.Key.is_valid?("x")
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(key) when is_binary(key), do: true
  def is_valid?(_key), do: false
end
