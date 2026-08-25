# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.Watchlist do
  @moduledoc """
  """

  @typedoc """
  "Watchlist"=>[{"properties",[{"accountId",[{"type","string"}]},{"name",[{"type","string"}]},{"status",[{"enum",["UNCHANGED","CREATED","UPDATED","DELETED"]},{"type","string"}]},{"watchlistId",[{"type","string"}]},{"watchlistItems",[{"items",[{"$dict","Item"}]},{"type","array"}]}]},{"required",["watchlistItems"]},{"type","object"}]
    {"properties",
     [
       {"accountId", [ {"type", "string"} ]},
       {"name", [ {"type", "string"} ]},
       {"status", [ {"enum", ["UNCHANGED", "CREATED", "UPDATED", "DELETED"]}, {"type", "string"} ]},
       {"watchlistId", [ {"type", "string"} ]},j
       {"watchlistItems", [ {"items", [ {"$dict", "Item"} ]}, {"type", "array"} ]}
     ]
    },
    {"required", ["watchlistItems"]},
    {"type", "object"}
  """
  @type t :: %{
          accountId: binary() | String.t(),
          name: binary() | String.t(),
          status: Status.t(),
          watchlistId: binary() | String.t(),
          watchlistItems: Item.t()
        }
  @spec is_valid?(t) :: boolean()
  def is_valid?(list) when is_map(list) do
    is_binary(list.accountId) &&
      is_binary(list.name) &&
      TDAmeritrade.Types.Status.is_valid?(list.status) &&
      is_binary(list.watchlistId) &&
      for i <- list.watchlistItems, reduce: true do
        acc -> acc and TDAmeritrade.Types.Item.is_valid?(i)
      end
  end

  def is_valid?(_list), do: false
end
