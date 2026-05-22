# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -
defmodule TDAmeritrade.Orders.OrderLeg do
  @moduledoc "Fluent builder for a single order leg."

  defstruct instruction: nil,
            quantity: nil,
            price: nil,
            quantity_type: nil,
            asset_type: nil,
            symbol: nil,
            position_effect: nil

  def new, do: %__MODULE__{}

  def instruction(%__MODULE__{} = leg, value) when is_binary(value) do
    %{leg | instruction: value}
  end

  def quantity(%__MODULE__{} = leg, value) when is_number(value) do
    %{leg | quantity: value}
  end

  def price(%__MODULE__{} = leg, value) when is_number(value) do
    %{leg | price: value}
  end

  def quantity_type(%__MODULE__{} = leg, value) when is_binary(value) do
    %{leg | quantity_type: value}
  end

  def asset(%__MODULE__{} = leg, asset_type, symbol)
      when is_binary(asset_type) and is_binary(symbol) do
    %{leg | asset_type: asset_type, symbol: symbol}
  end

  def position_effect(%__MODULE__{} = leg, value) when is_binary(value) do
    %{leg | position_effect: value}
  end

  def to_open(%__MODULE__{} = leg), do: position_effect(leg, "OPENING")
  def to_close(%__MODULE__{} = leg), do: position_effect(leg, "CLOSING")

  def copy(%__MODULE__{} = leg), do: %{leg | __struct__: __MODULE__}

  @doc "Converts the leg into the wire format expected by TD."
  def to_map(%__MODULE__{} = leg) do
    %{
      "instruction" => leg.instruction,
      "quantity" => leg.quantity,
      "price" => leg.price,
      "quantityType" => leg.quantity_type,
      "positionEffect" => leg.position_effect,
      "instrument" => %{
        "symbol" => leg.symbol,
        "assetType" => leg.asset_type
      }
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
