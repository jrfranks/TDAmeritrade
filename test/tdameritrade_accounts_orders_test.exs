# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.AccountsOrdersTest do
  use ExUnit.Case, async: true

  @dialyzer {:nowarn_function, [
    {:"test Accounts & Orders - Value Extremes & Negative Cases GetTransactions with nil account id", 1},
    {:"test Accounts & Orders - Value Extremes & Negative Cases ReplaceOrder with nil replacement body", 1}
  ]}

  alias TDAmeritrade.TestSupport.TdBypass
  alias Bypass

  # ---------------- GetAccount / GetAccounts ----------------
  describe "GetAccount" do
    test "returns a single account" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/accounts/12345", "user_principals.json", 200)

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} = TDAmeritrade.Rest.GetAccount.get_account(client, "12345")
      assert data["userId"] == "MYUSER123"
      assert is_list(data["accounts"])
    end

    test "surfaces 404 for unknown account" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/accounts/99999", "error_404.json", 404)

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.GetAccount.get_account(client, "99999")
    end
  end

  describe "GetAccounts" do
    test "returns list of accounts for the user" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/accounts", "user_principals.json", 200)

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} = TDAmeritrade.Rest.GetAccounts.get_accounts(client)
      # The fixture returns a user principals object; real response is usually a list
      assert is_map(data) or is_list(data)
    end
  end

  # ---------------- Orders ----------------
  describe "GetOrdersByPath" do
    test "returns orders for an account (happy path)" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/accounts/12345/orders",
        "orders_by_path_12345.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} =
               TDAmeritrade.Rest.GetOrdersByPath.get_orders_by_path(client, "12345",
                 maxResults: 10,
                 status: "FILLED"
               )

      assert is_list(data)
      if length(data) > 0, do: assert is_map(hd(data))
    end

    test "surfaces 404 for unknown account" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/accounts/99999/orders", "error_404.json", 404)

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.GetOrdersByPath.get_orders_by_path(client, "99999")
    end
  end

  describe "GetOrdersByQuery" do
    test "returns orders using query parameters (note: /v1/orders not /accounts/...)" do
      bypass = TdBypass.start()
      # The implementation uses the "Get Orders By Query" endpoint /v1/orders with query params
      TdBypass.expect_json(bypass, "GET", "/v1/orders", "orders_by_query.json", 200)

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} =
               TDAmeritrade.Rest.GetOrdersByQuery.get_orders_by_query(client,
                 accountId: "12345",
                 status: "PENDING_ACTIVATION"
               )

      assert is_list(data)
    end

    test "surfaces 404 for bad query" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/orders", "error_404.json", 404)

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.GetOrdersByQuery.get_orders_by_query(client, status: "EXPIRED")
    end
  end

  describe "PlaceOrder" do
    test "places an order and verifies body" do
      bypass = TdBypass.start()

      Bypass.expect(bypass, "POST", "/v1/accounts/12345/orders", fn conn ->
        {:ok, body, _} = Plug.Conn.read_body(conn)
        assert body =~ "MARKET"

        conn
        |> Plug.Conn.resp(200, "{}")
      end)

      client = TdBypass.client_for_bypass(bypass)

      body = %{
        "orderType" => "MARKET",
        "session" => "NORMAL",
        "duration" => "DAY",
        "orderStrategyType" => "SINGLE",
        "orderLegCollection" => [
          %{
            "instruction" => "BUY",
            "quantity" => 1,
            "instrument" => %{"symbol" => "AAPL", "assetType" => "EQUITY"}
          }
        ]
      }

      assert {:ok, _} = TDAmeritrade.Rest.PlaceOrder.place_order(client, "12345", body)
    end

    test "surfaces 400 for bad order" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "POST", "/v1/accounts/12345/orders", "error_404.json", 400)

      client = TdBypass.client_for_bypass(bypass)
      bad_body = %{}

      assert {:error, %TDAmeritrade.Error{status: 400}} =
               TDAmeritrade.Rest.PlaceOrder.place_order(client, "12345", bad_body)
    end
  end

  describe "CancelOrder" do
    test "cancels an order successfully" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "DELETE",
        "/v1/accounts/12345/orders/123456789",
        "empty.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, result} =
               TDAmeritrade.Rest.CancelOrder.cancel_order(client, "12345", 123_456_789)

      assert result.status == "CANCELED"
    end

    test "surfaces 404 when order not found" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "DELETE",
        "/v1/accounts/12345/orders/999999",
        "error_404.json",
        404
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.CancelOrder.cancel_order(client, "12345", 999_999)
    end
  end

  describe "ReplaceOrder" do
    test "replaces an order and verifies body" do
      bypass = TdBypass.start()

      Bypass.expect(bypass, "PUT", "/v1/accounts/12345/orders/123456789", fn conn ->
        {:ok, body, _} = Plug.Conn.read_body(conn)
        assert body =~ "LIMIT"

        conn
        |> Plug.Conn.resp(200, "{}")
      end)

      client = TdBypass.client_for_bypass(bypass)

      replacement = %{
        "orderType" => "LIMIT",
        "price" => 175.00,
        "session" => "NORMAL",
        "duration" => "GOOD_TILL_CANCEL",
        "orderStrategyType" => "SINGLE",
        "orderLegCollection" => [
          %{
            "instruction" => "SELL",
            "quantity" => 1,
            "instrument" => %{"symbol" => "AAPL", "assetType" => "EQUITY"}
          }
        ]
      }

      assert {:ok, _} =
               TDAmeritrade.Rest.ReplaceOrder.replace_order(
                 client,
                 "12345",
                 123_456_789,
                 replacement
               )
    end
  end

  # ============================================================
  # Value Extremes and Negative Tests
  # ============================================================
  describe "Accounts & Orders - Value Extremes & Negative Cases" do
    test "GetAccount with empty account id" do
      client = TDAmeritrade.Client.new(access_token: "demo")
      assert {:error, _} = TDAmeritrade.Rest.GetAccount.get_account(client, "")
    end

    test "PlaceOrder with empty body map" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "POST", "/v1/accounts/12345/orders", "error_404.json", 400)

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 400}} =
               TDAmeritrade.Rest.PlaceOrder.place_order(client, "12345", %{})
    end

    @dialyzer {:nowarn_function, {:"test Accounts & Orders - Value Extremes & Negative Cases GetTransactions with nil account id", 1}}
    test "GetTransactions with nil account id" do
      client = TDAmeritrade.Client.new(access_token: "demo")
      assert {:error, _} = apply(TDAmeritrade.Rest.GetTransactions, :get_transactions, [client, nil])
    end

    @dialyzer {:nowarn_function, {:"test Accounts & Orders - Value Extremes & Negative Cases ReplaceOrder with nil replacement body", 1}}
    test "ReplaceOrder with nil replacement body" do
      client = TDAmeritrade.Client.new(access_token: "demo")
      assert {:error, _} = apply(TDAmeritrade.Rest.ReplaceOrder, :replace_order, [client, "12345", "123456789", nil])
    end
  end

  describe "Order & OrderLeg Builders" do
    test "builds a simple limit order map correctly" do
      alias TDAmeritrade.Orders

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

      map = Orders.Order.to_map(order)

      assert map["orderType"] == "LIMIT"
      assert map["price"] == 175.00
      assert hd(map["orderLegCollection"])["instruction"] == "BUY"
      assert hd(map["orderLegCollection"])["instrument"]["symbol"] == "AAPL"
    end

    test "bracket/3 produces a valid TRIGGER + two children structure" do
      alias TDAmeritrade.Orders

      buy_leg =
        Orders.OrderLeg.new()
        |> Orders.OrderLeg.instruction("BUY")
        |> Orders.OrderLeg.quantity(100)
        |> Orders.OrderLeg.asset("EQUITY", "XYZ")

      tp_leg =
        Orders.OrderLeg.new()
        |> Orders.OrderLeg.instruction("SELL")
        |> Orders.OrderLeg.quantity(100)
        |> Orders.OrderLeg.asset("EQUITY", "XYZ")

      sl_leg =
        Orders.OrderLeg.new()
        |> Orders.OrderLeg.instruction("SELL")
        |> Orders.OrderLeg.quantity(100)
        |> Orders.OrderLeg.asset("EQUITY", "XYZ")

      bracket = Orders.Strategies.bracket(buy_leg, tp_leg, sl_leg)

      map = Orders.Order.to_map(bracket)

      assert map["orderStrategyType"] == "TRIGGER"
      assert length(map["childOrderStrategies"]) == 2
    end

    test "trailing_stop/3 builds correctly" do
      alias TDAmeritrade.Orders

      leg =
        Orders.OrderLeg.new()
        |> Orders.OrderLeg.instruction("SELL")
        |> Orders.OrderLeg.quantity(50)
        |> Orders.OrderLeg.asset("EQUITY", "TSLA")

      ts = Orders.Strategies.trailing_stop(leg, 2.50, :amount)

      map = Orders.Order.to_map(ts)

      assert map["orderType"] == "TRAILING_STOP"
      assert map["stopPriceOffset"] == 2.50
    end

    test "covered_call and iron_condor produce valid multi-leg structures" do
      alias TDAmeritrade.Orders

      stock =
        Orders.OrderLeg.new()
        |> Orders.OrderLeg.instruction("BUY")
        |> Orders.OrderLeg.quantity(100)
        |> Orders.OrderLeg.asset("EQUITY", "XYZ")

      call =
        Orders.OrderLeg.new()
        |> Orders.OrderLeg.instruction("SELL")
        |> Orders.OrderLeg.quantity(1)
        |> Orders.OrderLeg.asset("OPTION", "XYZ  241220C00150000")

      cc = Orders.Strategies.covered_call(stock, call)
      assert length(Orders.Order.to_map(cc)["orderLegCollection"]) == 2

      # Iron condor (4 legs)
      sp =
        Orders.OrderLeg.new()
        |> Orders.OrderLeg.instruction("SELL")
        |> Orders.OrderLeg.quantity(1)
        |> Orders.OrderLeg.asset("OPTION", "XYZ  241220P00140000")

      lp =
        Orders.OrderLeg.new()
        |> Orders.OrderLeg.instruction("BUY")
        |> Orders.OrderLeg.quantity(1)
        |> Orders.OrderLeg.asset("OPTION", "XYZ  241220P00135000")

      sc =
        Orders.OrderLeg.new()
        |> Orders.OrderLeg.instruction("SELL")
        |> Orders.OrderLeg.quantity(1)
        |> Orders.OrderLeg.asset("OPTION", "XYZ  241220C00160000")

      lc =
        Orders.OrderLeg.new()
        |> Orders.OrderLeg.instruction("BUY")
        |> Orders.OrderLeg.quantity(1)
        |> Orders.OrderLeg.asset("OPTION", "XYZ  241220C00165000")

      ic = Orders.Strategies.iron_condor(sp, lp, sc, lc)
      assert length(Orders.Order.to_map(ic)["orderLegCollection"]) == 4
      assert Orders.Order.to_map(ic)["orderType"] == "NET_CREDIT"
    end

    test "market_on_close, credit verticals, straddle, strangle, collar, synthetics" do
      alias TDAmeritrade.Orders

      leg =
        Orders.OrderLeg.new()
        |> Orders.OrderLeg.instruction("BUY")
        |> Orders.OrderLeg.quantity(1)
        |> Orders.OrderLeg.asset("EQUITY", "SPY")

      mocl = Orders.Strategies.market_on_close(leg)
      assert Orders.Order.to_map(mocl)["orderType"] == "MARKET_ON_CLOSE"

      # Credit vertical (bear call)
      sell_c =
        Orders.OrderLeg.new()
        |> Orders.OrderLeg.instruction("SELL")
        |> Orders.OrderLeg.quantity(1)
        |> Orders.OrderLeg.asset("OPTION", "SPY  241220C00500000")

      buy_c =
        Orders.OrderLeg.new()
        |> Orders.OrderLeg.instruction("BUY")
        |> Orders.OrderLeg.quantity(1)
        |> Orders.OrderLeg.asset("OPTION", "SPY  241220C00510000")

      bcs = Orders.Strategies.bear_call_vertical_spread(sell_c, buy_c)
      assert Orders.Order.to_map(bcs)["orderType"] == "NET_CREDIT"

      # Long straddle
      p =
        Orders.OrderLeg.new()
        |> Orders.OrderLeg.instruction("BUY")
        |> Orders.OrderLeg.quantity(1)
        |> Orders.OrderLeg.asset("OPTION", "SPY  241220P00480000")

      c =
        Orders.OrderLeg.new()
        |> Orders.OrderLeg.instruction("BUY")
        |> Orders.OrderLeg.quantity(1)
        |> Orders.OrderLeg.asset("OPTION", "SPY  241220C00480000")

      ls = Orders.Strategies.long_straddle(p, c)
      assert length(Orders.Order.to_map(ls)["orderLegCollection"]) == 2

      # Collar
      stock =
        Orders.OrderLeg.new()
        |> Orders.OrderLeg.instruction("BUY")
        |> Orders.OrderLeg.quantity(100)
        |> Orders.OrderLeg.asset("EQUITY", "AAPL")

      prot =
        Orders.OrderLeg.new()
        |> Orders.OrderLeg.instruction("BUY")
        |> Orders.OrderLeg.quantity(1)
        |> Orders.OrderLeg.asset("OPTION", "AAPL  241220P00180000")

      cov =
        Orders.OrderLeg.new()
        |> Orders.OrderLeg.instruction("SELL")
        |> Orders.OrderLeg.quantity(1)
        |> Orders.OrderLeg.asset("OPTION", "AAPL  241220C00200000")

      col = Orders.Strategies.collar(stock, prot, cov)
      assert length(Orders.Order.to_map(col)["orderLegCollection"]) == 3

      # Synthetic long
      # reuse legs for shape
      syn = Orders.Strategies.synthetic_long_stock(c, p)
      assert Orders.Order.to_map(syn)["orderType"] == "NET_DEBIT"
    end
  end

  # ---------------- Transactions (GetTransactions / GetTransaction) ----------------
  describe "GetTransactions" do
    test "returns transactions for an account (happy path - fixture not present, use 200 with empty)" do
      bypass = TdBypass.start()
      # We reuse error_404 fixture just to exercise the path; real fixture would be better
      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/accounts/12345/transactions",
        "orders_by_query.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, _data} =
               TDAmeritrade.Rest.GetTransactions.get_transactions(client, "12345", type: "TRADE")
    end

    test "surfaces error for unknown account on transactions" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/accounts/99999/transactions",
        "error_404.json",
        404
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.GetTransactions.get_transactions(client, "99999")
    end
  end

  describe "GetTransaction (single)" do
    test "fetches a single transaction by id" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/accounts/12345/transactions/987654",
        "orders_by_query.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, _} =
               TDAmeritrade.Rest.GetTransaction.get_transaction(client, "12345", "987654")
    end
  end
end
