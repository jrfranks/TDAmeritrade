# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.SecuritiesAccount do
  @moduledoc """
    %{
      "SecuritiesAccount" => [
        {"discriminator","type"},
        {
          "properties",[
            {"accountId",[{"type","string"}]},
            {"isClosingOnlyRestricted",[{"default",false},{"type","boolean"}]},
            {"isDayTrader",[{"default",false},{"type","boolean"}]},
            {"orderStrategies",[ {"items",[{"$dict","OrderGet"}]}, {"type","array"} ]},
            {"positions",[{"items",[{"$dict","Position"}]},{"type","array"}]},
            {"roundTrips",[{"format","int32"},{"type","integer"}]},
            {"type",[{"enum",["CASH","MARGIN"]},{"type","string"}]}
          ]
        },
        {"type","object"}
      ]
    }
  """
  @typedoc """

  """
  @type t :: map()

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.SecuritiesAccount.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.SecuritiesAccount.is_valid?(x)
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(account) when map_size(account) == 0, do: true
  def is_valid?(account) when is_map(account), do: true
  def is_valid?(_account), do: false
end
