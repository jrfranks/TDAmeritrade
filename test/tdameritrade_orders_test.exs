# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.OrdersTest do
  use ExUnit.Case, async: true

  alias TDAmeritrade.Orders.Order
  alias TDAmeritrade.Orders.OrderLeg
  alias TDAmeritrade.Orders.Strategies

  defp leg(instruction, qty, symbol, asset_type \\ "EQUITY") do
    OrderLeg.new()
    |> OrderLeg.instruction(instruction)
    |> OrderLeg.quantity(qty)
    |> OrderLeg.asset(asset_type, symbol)
  end

  describe "low-level leg and order builders" do
    test "OrderLeg fluent API" do
      l = leg("BUY", 100, "AAPL")
      assert l.instruction == "BUY"
      assert l.quantity == 100
      assert l.symbol == "AAPL"

      m = OrderLeg.to_map(l)
      assert m["instruction"] == "BUY"
      assert m["instrument"]["symbol"] == "AAPL"
    end

    test "Order.add_leg / delete_leg / to_map" do
      o =
        Order.new()
        |> Order.order_type("LIMIT")
        |> Order.price(123.45)
        |> Order.add_leg(leg("BUY", 10, "XYZ"))

      assert length(o.order_leg_collection) == 1

      o2 = Order.delete_leg(o, 0)
      assert o2.order_leg_collection == []

      map = Order.to_map(o)
      assert map["orderType"] == "LIMIT"
      assert map["price"] == 123.45
      assert length(map["orderLegCollection"]) == 1
    end
  end

  describe "high-level strategy constructors" do
    test "market/1, limit/2, stop/2, stop_limit/3" do
      assert %Order{} = Strategies.market(leg("BUY", 1, "AAPL"))
      assert %Order{} = Strategies.limit(leg("SELL", 2, "MSFT"), 250.0)
      assert %Order{} = Strategies.stop(leg("SELL", 5, "XYZ"), 45.0)
      assert %Order{} = Strategies.stop_limit(leg("BUY", 1, "TSLA"), 240.0, 239.5)
    end

    test "trailing_stop and trailing_stop_limit" do
      assert %Order{} = Strategies.trailing_stop(leg("SELL", 10, "SPY"), 1.50, :amount)
      assert %Order{} = Strategies.trailing_stop(leg("SELL", 10, "SPY"), 2.5, :percent)
      assert %Order{} = Strategies.trailing_stop_limit(leg("SELL", 5, "QQQ"), 1.0, 0.5, :amount)
    end

    test "bracket, oco, trigger" do
      primary = leg("BUY", 100, "XYZ")
      tp = leg("SELL", 100, "XYZ")
      sl = leg("SELL", 100, "XYZ")

      assert %Order{} = Strategies.bracket(primary, tp, sl)
      assert %Order{} = Strategies.oco(tp, sl)
      assert %Order{} = Strategies.trigger(primary, Strategies.market(tp))
    end

    test "market_on_close and limit_on_close" do
      assert %Order{} = Strategies.market_on_close(leg("BUY", 50, "AAPL"))
      assert %Order{} = Strategies.limit_on_close(leg("SELL", 50, "AAPL"), 180.0)
    end

    # --- Options & multi-leg strategies ---

    test "covered_call" do
      stock = leg("BUY", 100, "AAPL")
      call = leg("SELL_TO_OPEN", 1, "AAPL  240119C00180000", "OPTION")
      assert %Order{} = Strategies.covered_call(stock, call)
    end

    test "cash_secured_put" do
      put = leg("SELL_TO_OPEN", 1, "AAPL  240119P00170000", "OPTION")
      assert %Order{} = Strategies.cash_secured_put(put)
    end

    test "vertical spreads" do
      buy_call = leg("BUY_TO_OPEN", 1, "SPY  240119C00450000", "OPTION")
      sell_call = leg("SELL_TO_OPEN", 1, "SPY  240119C00455000", "OPTION")
      assert %Order{} = Strategies.bull_call_vertical_spread(buy_call, sell_call)

      sell_put = leg("SELL_TO_OPEN", 1, "SPY  240119P00440000", "OPTION")
      buy_put = leg("BUY_TO_OPEN", 1, "SPY  240119P00435000", "OPTION")
      assert %Order{} = Strategies.bull_put_vertical_spread(sell_put, buy_put)
    end

    test "iron_condor (4 legs)" do
      sp = leg("SELL_TO_OPEN", 1, "SPY  240119P00440000", "OPTION")
      lp = leg("BUY_TO_OPEN", 1, "SPY  240119P00435000", "OPTION")
      sc = leg("SELL_TO_OPEN", 1, "SPY  240119C00455000", "OPTION")
      lc = leg("BUY_TO_OPEN", 1, "SPY  240119C00460000", "OPTION")

      assert %Order{} = Strategies.iron_condor(sp, lp, sc, lc)
    end

    test "butterflies" do
      low = leg("BUY_TO_OPEN", 1, "SPY  240119C00440000", "OPTION")
      mid = leg("SELL_TO_OPEN", 2, "SPY  240119C00450000", "OPTION")
      high = leg("BUY_TO_OPEN", 1, "SPY  240119C00460000", "OPTION")

      assert %Order{} = Strategies.call_butterfly(low, mid, high)
      assert %Order{} = Strategies.put_butterfly(high, mid, low)
    end

    test "straddles and strangles" do
      put = leg("BUY_TO_OPEN", 1, "SPY  240119P00450000", "OPTION")
      call = leg("BUY_TO_OPEN", 1, "SPY  240119C00450000", "OPTION")

      assert %Order{} = Strategies.long_straddle(put, call)
      assert %Order{} = Strategies.short_straddle(put, call)

      otm_put = leg("BUY_TO_OPEN", 1, "SPY  240119P00440000", "OPTION")
      otm_call = leg("BUY_TO_OPEN", 1, "SPY  240119C00460000", "OPTION")
      assert %Order{} = Strategies.long_strangle(otm_put, otm_call)
      assert %Order{} = Strategies.short_strangle(otm_put, otm_call)
    end

    test "collar, calendar, diagonal" do
      stock = leg("BUY_TO_OPEN", 100, "AAPL")
      put = leg("BUY_TO_OPEN", 1, "AAPL  240119P00180000", "OPTION")
      call = leg("SELL_TO_OPEN", 1, "AAPL  240119C00190000", "OPTION")

      assert %Order{} = Strategies.collar(stock, put, call)

      near = leg("BUY_TO_OPEN", 1, "SPY  240119C00450000", "OPTION")
      far = leg("BUY_TO_OPEN", 1, "SPY  240216C00450000", "OPTION")
      assert %Order{} = Strategies.calendar_spread(near, far)
      assert %Order{} = Strategies.diagonal_spread(near, far)
    end

    test "synthetics" do
      long_call = leg("BUY_TO_OPEN", 1, "SPY  240119C00450000", "OPTION")
      short_put = leg("SELL_TO_OPEN", 1, "SPY  240119P00450000", "OPTION")
      assert %Order{} = Strategies.synthetic_long_stock(long_call, short_put)

      short_call = leg("SELL_TO_OPEN", 1, "SPY  240119C00450000", "OPTION")
      long_put = leg("BUY_TO_OPEN", 1, "SPY  240119P00450000", "OPTION")
      assert %Order{} = Strategies.synthetic_short_stock(short_call, long_put)
    end
  end

  describe "to_map on complex orders" do
    test "bracket produces childOrderStrategies" do
      primary = leg("BUY", 100, "XYZ")
      tp = leg("SELL", 100, "XYZ")
      sl = leg("SELL", 100, "XYZ")

      order = Strategies.bracket(primary, tp, sl)
      m = Order.to_map(order)

      assert m["orderStrategyType"] == "TRIGGER"
      assert length(m["childOrderStrategies"]) == 2
    end
  end
end
