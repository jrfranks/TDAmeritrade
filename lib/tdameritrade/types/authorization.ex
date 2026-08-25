# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.Authorization do
  @moduledoc """
  %{
    "Authorization" => [
       {"advancedMargin", [{"default", false}, {"type", "boolean"}]},
       {"apex", [{"default", false}, {"type", "boolean"}]},
       {"levelTwoQuotes", [{"default", false}, {"type", "boolean"}]},
       {"marginTrading", [{"default", false}, {"type", "boolean"}]},
       {"optionTradingLevel", [{"enum", ["COVERED", "FULL", "LONG", "SPREAD", "NONE"]}, {"type", "string"}]},
       {"scottradeAccount", [{"default", false}, {"type", "boolean"}]},
       {"stockTrading", [{"default", false}, {"type", "boolean"}]},
       {"streamerAccess", [{"default", false}, {"type", "boolean"}]},
       {"streamingNews", [{"default", false}, {"type", "boolean"}]}
    ]
  }
  """

  @typedoc """

  """
  @type t :: map()

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.Authorization.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.Authorization.is_valid?(x)
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(auth) when map_size(auth) == 0, do: true
  def is_valid?(auth) when is_map(auth), do: true
  def is_valid?(_auth), do: false
end
