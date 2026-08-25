# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.AssetType do
  @typedoc """
  A string that is one of: "EQUITY", "OPTION", "MUTUAL_FUND", "FIXED_INCOME", or "INDEX"
  """
  @type t :: binary() | String.t()

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.AssetType.is_valid?(%{})
    false

    iex> TDAmeritrade.Types.AssetType.is_valid?("xxx")
    false

    iex> TDAmeritrade.Types.AssetType.is_valid?(:equity)
    true

    iex> TDAmeritrade.Types.AssetType.is_valid?("EQUITY")
    true

    iex> TDAmeritrade.Types.AssetType.is_valid?(:option)
    true

    iex> TDAmeritrade.Types.AssetType.is_valid?("OPTION")
    true

    iex> TDAmeritrade.Types.AssetType.is_valid?(:mutual_fund)
    true

    iex> TDAmeritrade.Types.AssetType.is_valid?("MUTUAL_FUND")
    true

    iex> TDAmeritrade.Types.AssetType.is_valid?(:option)
    true

    iex> TDAmeritrade.Types.AssetType.is_valid?("OPTION")
    true

    iex> TDAmeritrade.Types.AssetType.is_valid?(:fixed_income)
    true

    iex> TDAmeritrade.Types.AssetType.is_valid?("FIXED_INCOME")
    true

    iex> TDAmeritrade.Types.AssetType.is_valid?(:index)
    true

    iex> TDAmeritrade.Types.AssetType.is_valid?("INDEX")
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(asset_type) when is_atom(asset_type) do
    is_valid?(Atom.to_string(asset_type))
  end

  def is_valid?(asset_type) when is_binary(asset_type) do
    asset_type = String.upcase(asset_type)

    asset_type == "EQUITY" ||
      asset_type == "OPTION" ||
      asset_type == "MUTUAL_FUND" ||
      asset_type == "FIXED_INCOME" ||
      asset_type == "INDEX"
  end

  def is_valid?(_asset_type), do: false
end
