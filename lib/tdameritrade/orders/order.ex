# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Orders.Order do
  @moduledoc """
  Low-level fluent builder for a complete order.

  This module focuses on constructing the order data structure and converting
  it to the wire format. High-level strategy constructors (bracket, iron condor,
  butterflies, etc.) live in `TDAmeritrade.Orders.Strategies`.
  """

  alias TDAmeritrade.Orders.OrderLeg

  defstruct price: nil,
            order_type: nil,
            stop_price_offset: nil,
            stop_type: nil,
            stop_price_link_type: nil,
            stop_price_link_basis: nil,
            stop_price: nil,
            activation_price: nil,
            session: nil,
            duration: nil,
            cancel_time: nil,
            price_link_type: nil,
            price_link_basis: nil,
            special_instruction: nil,
            requested_destination: nil,
            complex_order_strategy_type: nil,
            order_strategy_type: nil,
            order_leg_collection: [],
            child_order_strategies: []

  def new, do: %__MODULE__{}

  # --- Fluent setters ---
  def price(%__MODULE__{} = o, value) when is_number(value), do: %{o | price: value}
  def order_type(%__MODULE__{} = o, value) when is_binary(value), do: %{o | order_type: value}
  def stop_price_offset(%__MODULE__{} = o, value), do: %{o | stop_price_offset: value}
  def stop_type(%__MODULE__{} = o, value), do: %{o | stop_type: value}
  def stop_price_link_type(%__MODULE__{} = o, value), do: %{o | stop_price_link_type: value}
  def stop_price_link_basis(%__MODULE__{} = o, value), do: %{o | stop_price_link_basis: value}
  def stop_price(%__MODULE__{} = o, value), do: %{o | stop_price: value}
  def activation_price(%__MODULE__{} = o, value), do: %{o | activation_price: value}
  def session(%__MODULE__{} = o, value), do: %{o | session: value}

  def duration(%__MODULE__{} = o, value, cancel_time \\ nil),
    do: %{o | duration: value, cancel_time: cancel_time}

  def price_link_type(%__MODULE__{} = o, value), do: %{o | price_link_type: value}
  def price_link_basis(%__MODULE__{} = o, value), do: %{o | price_link_basis: value}
  def special_instruction(%__MODULE__{} = o, value), do: %{o | special_instruction: value}
  def requested_destination(%__MODULE__{} = o, value), do: %{o | requested_destination: value}

  def complex_order_type(%__MODULE__{} = o, value),
    do: %{o | complex_order_strategy_type: value}

  def order_strategy_type(%__MODULE__{} = o, value) when is_binary(value),
    do: %{o | order_strategy_type: value}

  # --- Leg & child management ---
  def add_leg(%__MODULE__{} = o, leg) when is_map(leg) do
    %{o | order_leg_collection: o.order_leg_collection ++ [leg]}
  end

  def delete_leg(%__MODULE__{} = o, index) when is_integer(index) do
    %{o | order_leg_collection: List.delete_at(o.order_leg_collection, index)}
  end

  def add_child_order_strategy(%__MODULE__{} = o, child) when is_map(child) do
    %{o | child_order_strategies: o.child_order_strategies ++ [child]}
  end

  @doc "Converts the order (and all legs/children) into the TD wire format."
  def to_map(%__MODULE__{} = order) do
    base = %{
      "price" => order.price,
      "orderType" => order.order_type,
      "stopPriceOffset" => order.stop_price_offset,
      "stopType" => order.stop_type,
      "stopPriceLinkType" => order.stop_price_link_type,
      "stopPriceLinkBasis" => order.stop_price_link_basis,
      "stopPrice" => order.stop_price,
      "activationPrice" => order.activation_price,
      "session" => order.session,
      "duration" => order.duration,
      "cancelTime" => order.cancel_time,
      "priceLinkType" => order.price_link_type,
      "priceLinkBasis" => order.price_link_basis,
      "specialInstruction" => order.special_instruction,
      "requestedDestination" => order.requested_destination,
      "complexOrderStrategyType" => order.complex_order_strategy_type,
      "orderStrategyType" => order.order_strategy_type,
      "orderLegCollection" => Enum.map(order.order_leg_collection, &OrderLeg.to_map/1),
      "childOrderStrategies" => Enum.map(order.child_order_strategies, &to_map/1)
    }

    base
    |> Enum.reject(fn {_k, v} -> is_nil(v) or v == [] or v == "" end)
    |> Map.new()
  end
end
