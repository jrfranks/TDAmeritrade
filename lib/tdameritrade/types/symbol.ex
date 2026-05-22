
defmodule TDAmeritrade.Types.Symbol do
  @moduledoc """
  Symbol typedef, validation, and manipulation functions
  """
  @symbol_regex ~r'^\${0,1}[A-Z]+([./p-][A-Z]+|\+|/WS){0,1}$'

  @typedoc """
  TDAmeritrade uses the following symbology when specifying instruments:

  | Service Name     | Display/Input | Stream Notation | Example |
  | :--------------- | :-------: | :-------: | :---------------- |
  | Class            | .         | /         | BRK.A  -> BRK/A   |
  | Index/Indicators | $         | $         | $DJI              |
  | Preferred        | -         | p         | PRE-A  -> PREpA   |
  | Warrants         | +         | /WS       | BOO+   ->  BOO/WS |

  Regex: #{Kernel.inspect(@symbol_regex)}
  """
  @type t :: binary() | String.t()

  @doc """
  Examples
    iex> TDAmeritrade.Types.Symbol.is_valid?("")
    false
    iex> TDAmeritrade.Types.Symbol.is_valid?("ABC")
    true
    iex> TDAmeritrade.Types.Symbol.is_valid?("ABC.X")
    true
    iex> TDAmeritrade.Types.Symbol.is_valid?("ABC/X")
    true
    iex> TDAmeritrade.Types.Symbol.is_valid?("$ABC")
    true
    iex> TDAmeritrade.Types.Symbol.is_valid?("$ABC.X")
    true
    iex> TDAmeritrade.Types.Symbol.is_valid?("$ABC/X")
    true
    iex> TDAmeritrade.Types.Symbol.is_valid?("ABC-X")
    true
    iex> TDAmeritrade.Types.Symbol.is_valid?("ABCpX")
    true
    iex> TDAmeritrade.Types.Symbol.is_valid?("ABC+XX")
    false
    iex> TDAmeritrade.Types.Symbol.is_valid?("ABC+")
    true
    iex> TDAmeritrade.Types.Symbol.is_valid?("ABC/WS")
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(str) when is_binary(str) do
    case Regex.run(@symbol_regex, str) do
      nil -> false
      _ -> true
    end
  end

  def is_valid?(_), do: false
end
