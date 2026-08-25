# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Orders do
  @moduledoc """
  Fluent builders for constructing TD Ameritrade order payloads.

  These mirror the developer experience of the Python `td.orders.Order`
  and `td.orders.OrderLeg` classes while producing plain maps that can be
  passed directly to `TDAmeritrade.Rest.PlaceOrder.place_order/3`,
  `TDAmeritrade.Rest.CreateSavedOrder.create_saved_order/3`, etc.

  In addition to the low-level fluent setters, this module provides
  **high-level strategy constructors** for the most common advanced order types:

  - `bracket/3` / `bracket_buy/3` / `bracket_sell/3`
  - `oco/2`
  - `trigger/2`
  - `market/1`, `limit/2`, `stop/2`, `stop_limit/3`
  - `trailing_stop/3`, `trailing_stop_limit/4`
  - Market / Limit on close
  - Covered call, cash-secured put
  - All vertical spreads (debit + credit)
  - Iron condor, butterflies
  - Long/short straddle & strangle
  - Collar, calendar, diagonal
  - Synthetic long/short stock

  ## Example

      alias TDAmeritrade.Orders

      # Simple order
      order =
        Orders.Order.new()
        |> Orders.Order.order_type("LIMIT")
        |> Orders.Order.price(175.00)
        |> Orders.Order.session("NORMAL")
        |> Orders.Order.duration("GOOD_TILL_CANCEL")
        |> Orders.Order.order_strategy_type("SINGLE")
        |> Orders.Order.add_leg(
             Orders.OrderLeg.new()
             |> Orders.OrderLeg.instruction("BUY")
             |> Orders.OrderLeg.quantity(1)
             |> Orders.OrderLeg.asset("EQUITY", "AAPL")
           )

      {:ok, _} = TDAmeritrade.Rest.PlaceOrder.place_order(client, "12345", Orders.Order.to_map(order))

      # Advanced: Bracket order (very common pattern)
      buy  = Orders.OrderLeg.new() |> Orders.OrderLeg.instruction("BUY")  |> Orders.OrderLeg.quantity(100) |> Orders.OrderLeg.asset("EQUITY", "XYZ")
      tp   = Orders.OrderLeg.new() |> Orders.OrderLeg.instruction("SELL") |> Orders.OrderLeg.quantity(100) |> Orders.OrderLeg.asset("EQUITY", "XYZ")
      stop = Orders.OrderLeg.new() |> Orders.OrderLeg.instruction("SELL") |> Orders.OrderLeg.quantity(100) |> Orders.OrderLeg.asset("EQUITY", "XYZ")

      bracket = Orders.Strategies.bracket(buy, tp, stop)
  """

  # The actual implementations live in:
  #   - TDAmeritrade.Orders.OrderLeg  (lib/tdameritrade/orders/order_leg.ex)
  #   - TDAmeritrade.Orders.Order     (lib/tdameritrade/orders/order.ex)
  #
  # This file exists purely as a clean public namespace.
end
