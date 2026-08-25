# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.OrderActivity do
  @moduledoc """
  %{
    "OrderActivity" => [
      {"discriminator", "activityType"},
      {"properties",
       [{"activityType", [{"enum", ["EXECUTION", "ORDER_ACTION"]}, {"type", "string"}]}]},
      {"type", "object"}
    ]
  }
  """

  @typedoc """

  """
  @type t :: map()

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.OrderActivity.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.OrderActivity.is_valid?(x)
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(activity) when map_size(activity) == 0, do: true
  def is_valid?(activity) when is_map(activity), do: true
  def is_valid?(_activity), do: false
end
