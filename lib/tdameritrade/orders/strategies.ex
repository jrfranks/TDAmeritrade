# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Orders.Strategies do
  @moduledoc """
  High-level strategy constructors for common advanced order types.

  These functions produce complete `TDAmeritrade.Orders.Order` structures
  (including child orders where appropriate) that can be converted to maps
  and sent to the Place Order or Create Saved Order endpoints.

  ## Examples

      alias TDAmeritrade.Orders

      buy  = Orders.OrderLeg.new() |> Orders.OrderLeg.instruction("BUY")  |> ...
      tp   = Orders.OrderLeg.new() |> ...
      stop = Orders.OrderLeg.new() |> ...

      bracket = Orders.Strategies.bracket(buy, tp, stop)

      iron_condor = Orders.Strategies.iron_condor(short_put, long_put, short_call, long_call)
  """

  alias TDAmeritrade.Orders.Order

  @doc """
  Creates a classic bracket order (primary leg + take-profit child + stop-loss child).
  """
  def bracket(primary_leg, take_profit_leg, stop_loss_leg, _opts \\ []) do
    order =
      Order.new()
      |> Order.order_strategy_type("TRIGGER")
      |> Order.add_leg(primary_leg)

    take_profit =
      Order.new()
      |> Order.order_strategy_type("SINGLE")
      |> Order.add_leg(take_profit_leg)

    stop_loss =
      Order.new()
      |> Order.order_strategy_type("SINGLE")
      |> Order.add_leg(stop_loss_leg)

    order
    |> Order.add_child_order_strategy(take_profit)
    |> Order.add_child_order_strategy(stop_loss)
  end

  @doc "Creates a simple OCO (One-Cancels-Other) order with two legs."
  def oco(leg1, leg2) do
    Order.new()
    |> Order.order_strategy_type("OCO")
    |> Order.add_leg(leg1)
    |> Order.add_leg(leg2)
  end

  @doc "Creates a trigger (primary + one child) order."
  def trigger(primary_leg, child_order) do
    Order.new()
    |> Order.order_strategy_type("TRIGGER")
    |> Order.add_leg(primary_leg)
    |> Order.add_child_order_strategy(child_order)
  end

  # --- Basic order types ---

  def market(leg) do
    Order.new()
    |> Order.order_type("MARKET")
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(leg)
  end

  def limit(leg, price) do
    Order.new()
    |> Order.order_type("LIMIT")
    |> Order.price(price)
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(leg)
  end

  def stop(leg, stop_price) do
    Order.new()
    |> Order.order_type("STOP")
    |> Order.stop_price(stop_price)
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(leg)
  end

  def stop_limit(leg, stop_price, limit_price) do
    Order.new()
    |> Order.order_type("STOP_LIMIT")
    |> Order.stop_price(stop_price)
    |> Order.price(limit_price)
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(leg)
  end

  def trailing_stop(leg, offset, type \\ :amount) do
    Order.new()
    |> Order.order_type("TRAILING_STOP")
    |> Order.stop_price_offset(offset)
    |> Order.stop_type(if type == :percent, do: "PERCENT", else: "AMOUNT")
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(leg)
  end

  def trailing_stop_limit(leg, trail_offset, limit_offset, type \\ :amount) do
    Order.new()
    |> Order.order_type("TRAILING_STOP_LIMIT")
    |> Order.stop_price_offset(trail_offset)
    |> Order.price_link_basis(limit_offset)
    |> Order.stop_type(if type == :percent, do: "PERCENT", else: "AMOUNT")
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(leg)
  end

  def market_on_close(leg) do
    Order.new()
    |> Order.order_type("MARKET_ON_CLOSE")
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(leg)
  end

  def limit_on_close(leg, price) do
    Order.new()
    |> Order.order_type("LIMIT_ON_CLOSE")
    |> Order.price(price)
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(leg)
  end

  # --- Common advanced strategies ---

  def covered_call(stock_leg, call_leg) do
    Order.new()
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(stock_leg)
    |> Order.add_leg(call_leg)
  end

  def cash_secured_put(put_leg) do
    Order.new()
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(put_leg)
  end

  def iron_condor(short_put, long_put, short_call, long_call) do
    Order.new()
    |> Order.order_strategy_type("SINGLE")
    |> Order.order_type("NET_CREDIT")
    |> Order.add_leg(short_put)
    |> Order.add_leg(long_put)
    |> Order.add_leg(short_call)
    |> Order.add_leg(long_call)
  end

  def bull_call_vertical_spread(buy_leg, sell_leg) do
    Order.new()
    |> Order.order_strategy_type("SINGLE")
    |> Order.order_type("NET_DEBIT")
    |> Order.add_leg(buy_leg)
    |> Order.add_leg(sell_leg)
  end

  def bear_put_vertical_spread(buy_leg, sell_leg) do
    Order.new()
    |> Order.order_strategy_type("SINGLE")
    |> Order.order_type("NET_DEBIT")
    |> Order.add_leg(buy_leg)
    |> Order.add_leg(sell_leg)
  end

  def call_butterfly(low, middle, high) do
    Order.new()
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(low)
    |> Order.add_leg(middle)
    |> Order.add_leg(high)
  end

  def put_butterfly(high, middle, low) do
    Order.new()
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(high)
    |> Order.add_leg(middle)
    |> Order.add_leg(low)
  end

  def long_straddle(put_leg, call_leg) do
    Order.new()
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(put_leg)
    |> Order.add_leg(call_leg)
  end

  def short_straddle(put_leg, call_leg) do
    Order.new()
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(put_leg)
    |> Order.add_leg(call_leg)
  end

  def long_strangle(put_leg, call_leg) do
    Order.new()
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(put_leg)
    |> Order.add_leg(call_leg)
  end

  def short_strangle(put_leg, call_leg) do
    Order.new()
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(put_leg)
    |> Order.add_leg(call_leg)
  end

  def collar(stock_leg, put_leg, call_leg) do
    Order.new()
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(stock_leg)
    |> Order.add_leg(put_leg)
    |> Order.add_leg(call_leg)
  end

  def calendar_spread(near_leg, far_leg) do
    Order.new()
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(near_leg)
    |> Order.add_leg(far_leg)
  end

  def diagonal_spread(near_leg, far_leg) do
    Order.new()
    |> Order.order_strategy_type("SINGLE")
    |> Order.add_leg(near_leg)
    |> Order.add_leg(far_leg)
  end

  def synthetic_long_stock(long_call, short_put) do
    Order.new()
    |> Order.order_strategy_type("SINGLE")
    |> Order.order_type("NET_DEBIT")
    |> Order.add_leg(long_call)
    |> Order.add_leg(short_put)
  end

  def synthetic_short_stock(short_call, long_put) do
    Order.new()
    |> Order.order_strategy_type("SINGLE")
    |> Order.order_type("NET_CREDIT")
    |> Order.add_leg(short_call)
    |> Order.add_leg(long_put)
  end

  def bear_call_vertical_spread(sell_leg, buy_leg) do
    Order.new()
    |> Order.order_strategy_type("SINGLE")
    |> Order.order_type("NET_CREDIT")
    |> Order.add_leg(sell_leg)
    |> Order.add_leg(buy_leg)
  end

  def bull_put_vertical_spread(buy_leg, sell_leg) do
    Order.new()
    |> Order.order_strategy_type("SINGLE")
    |> Order.order_type("NET_CREDIT")
    |> Order.add_leg(buy_leg)
    |> Order.add_leg(sell_leg)
  end
end
