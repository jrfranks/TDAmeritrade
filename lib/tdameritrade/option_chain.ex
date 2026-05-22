# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.OptionChain do
  @moduledoc """
  Simple builder for TD Ameritrade Option Chain request payloads.

  Mirrors the Python `td.option_chain.OptionChain` class.

  ## Example

      chain =
        TDAmeritrade.OptionChain.new()
        |> TDAmeritrade.OptionChain.add_chain_key("symbol", "AAPL")
        |> TDAmeritrade.OptionChain.add_chain_key("contractType", "CALL")
        |> TDAmeritrade.OptionChain.add_chain_key("strikeCount", 5)

      {:ok, data} = TDAmeritrade.Rest.GetOptionChain.get_option_chain(client, chain)
  """

  defstruct chain_keys: %{}

  def new, do: %__MODULE__{}

  def add_chain_key(%__MODULE__{} = chain, key_name, key_value) when is_binary(key_name) do
    %{chain | chain_keys: Map.put(chain.chain_keys, key_name, key_value)}
  end

  @doc "Validates that at least a symbol is present (very light validation)."
  def validate_chain(%__MODULE__{chain_keys: keys}) do
    Map.has_key?(keys, "symbol") or Map.has_key?(keys, :symbol)
  end

  @doc "Converts the builder into the map shape expected by GetOptionChain."
  def to_map(%__MODULE__{} = chain) do
    chain.chain_keys
  end
end
