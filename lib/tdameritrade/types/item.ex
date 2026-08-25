# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.Item do
  @moduledoc """
  """

  @typedoc """
  %{
    "Item" => [
      {"properties",
       [
         {"averagePrice", [{"format", "double"}, {"minimum", 0.0}, {"type", "number"}]},
         {"commission", [{"format", "double"}, {"minimum", 0.0}, {"type", "number"}]},
         {"instrument", [{"$dict", "Instrument"}]},
         {"purchasedDate", [{"$dict", "DateParam"}]},
         {"quantity", [{"format", "double"}, {"type", "number"}]},
         {"sequenceId", [{"format", "int32"}, {"minimum", 0.0}, {"type", "integer"}]},
         {"status",
          [{"enum", ["UNCHANGED", "CREATED", "UPDATED", "DELETED"]}, {"type", "string"}]}
       ]},
      {"type", "object"}
    ]
  }
  """

  @type t :: %{
          averagePrice: float(),
          commission: float(),
          instrument: Instrument.t(),
          purchasedDate: DateParam.t(),
          quantity: float(),
          sequenceId: integer(),
          status: Status.t()
        }

  @spec is_valid?(t) :: boolean()
  def is_valid?(item) when is_map(item) do
    item.averagePrice >= 0.0 &&
      item.commission >= 0.0 &&
      TDAmeritrade.Types.Instrument.is_valid?(item.instrument) &&
      TDAmeritrade.Types.DateParam.is_valid?(item.purchaseDate) &&
      item.quantity >= 0.0 &&
      item.sequenceId >= 0 &&
      TDAmeritrade.Types.Status.is_valid?(item.status)
  end

  def is_valid?(_item), do: false
end
