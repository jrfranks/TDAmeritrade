# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.MarketDataTest do
  use ExUnit.Case, async: true

  alias TDAmeritrade.TestSupport.TdBypass

  # ---------------- GetMovers ----------------
  describe "GetMovers" do
    test "returns movers for a valid index (happy path)" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/marketdata/%24SPX.X/movers",
        "movers_SPX.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} =
               TDAmeritrade.Rest.GetMovers.get_movers(client, "$SPX.X",
                 direction: "up",
                 change: "percent"
               )

      assert is_list(data)
      assert Enum.any?(data, &(&1["symbol"] == "XYZ"))
      mover = hd(data)
      assert Map.has_key?(mover, "symbol")
    end

    test "surfaces 404 error for unknown movers" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/marketdata/UNKNOWN/movers", "error_404.json", 404)

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.GetMovers.get_movers(client, "UNKNOWN")
    end
  end

  # ---------------- SearchInstruments ----------------
  describe "SearchInstruments" do
    test "returns instrument data for symbol search" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/instruments", "search_instruments_AAPL.json", 200)

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} =
               TDAmeritrade.Rest.SearchInstruments.search_instruments(client, "AAPL",
                 projection: "symbol-search"
               )

      assert is_list(data)
      assert hd(data)["symbol"] == "AAPL"
    end

    test "returns 404 when no instruments match" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/instruments", "error_404.json", 404)

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.SearchInstruments.search_instruments(client, "ZZZZZZ")
    end
  end

  # ---------------- GetInstrument ----------------
  describe "GetInstrument" do
    test "returns instrument data for a valid cusip" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/instruments/037833100",
        "get_instrument_037833100.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} = TDAmeritrade.Rest.GetInstrument.get_instrument(client, "037833100")
      assert data["cusip"] == "037833100"
      assert data["symbol"] == "AAPL"
    end

    test "returns 404 for unknown cusip" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/instruments/000000000", "error_404.json", 404)

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.GetInstrument.get_instrument(client, "000000000")
    end
  end

  # ---------------- GetOptionChain ----------------
  describe "GetOptionChain" do
    test "returns option chain for a symbol" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/marketdata/chains", "option_chain_AAPL.json", 200)

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} =
               TDAmeritrade.Rest.GetOptionChain.get_option_chain(client, "AAPL",
                 contractType: "ALL"
               )

      assert is_map(data)
      assert data["symbol"] == "AAPL" or Map.has_key?(data, "underlying")
    end

    test "returns 404 for unknown symbol" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/marketdata/chains", "error_404.json", 404)

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.GetOptionChain.get_option_chain(client, "ZZZZZ")
    end
  end

  # ---------------- GetPriceHistory ----------------
  describe "GetPriceHistory" do
    test "returns price history for a symbol" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/marketdata/AAPL/pricehistory",
        "price_history_AAPL.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} =
               TDAmeritrade.Rest.GetPriceHistory.get_price_history(client, "AAPL",
                 periodType: "day"
               )

      assert is_map(data)
      assert Map.has_key?(data, "candles") or Map.has_key?(data, "symbol")
    end

    test "surfaces 404 for bad symbol" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/marketdata/ZZZZZ/pricehistory",
        "error_404.json",
        404
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.GetPriceHistory.get_price_history(client, "ZZZZZ")
    end
  end

  # ---------------- GetQuotes ----------------
  describe "GetQuotes" do
    test "returns quotes for multiple symbols" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/marketdata/quotes",
        "get_quotes_AAPL,MSFT.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} = TDAmeritrade.Rest.GetQuotes.get_quotes(client, "AAPL,MSFT")
      assert is_map(data)
      assert Map.has_key?(data, "AAPL") or Map.has_key?(data, "MSFT")
    end
  end

  # ---------------- GetOrder (related to market data flow) ----------------
  describe "GetOrder" do
    test "returns a single order" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/accounts/12345/orders/987654321",
        "order_market_buy.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, _order} = TDAmeritrade.Rest.GetOrder.get_order(client, "12345", 987_654_321)
    end

    test "404 for missing order" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/accounts/12345/orders/999999",
        "error_404.json",
        404
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.GetOrder.get_order(client, "12345", 999_999)
    end
  end

  # ---------------- GetHours (market hours) ----------------
  describe "GetHoursForASingleMarket" do
    test "returns hours for a market" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/marketdata/EQUITY/hours", "preferences.json", 200)

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, _} =
               TDAmeritrade.Rest.GetHoursForASingleMarket.get_hours_for_a_single_market(
                 client,
                 "EQUITY"
               )
    end
  end

  describe "GetHoursForMultipleMarkets" do
    test "returns hours for multiple markets" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/marketdata/hours", "user_principals.json", 200)

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, _} =
               TDAmeritrade.Rest.GetHoursForMultipleMarkets.get_hours_for_multiple_markets(client,
                 markets: "EQUITY"
               )
    end
  end

  # ---------------- GetQuote (consolidated) ----------------
  describe "GetQuote" do
    test "get_quote hits the correct path and returns parsed data" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/marketdata/AAPL/quotes",
        "get_quote_AAPL.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} = TDAmeritrade.Rest.GetQuote.get_quote(client, "AAPL")
      assert Map.has_key?(data, "AAPL")
      quote = data["AAPL"]
      assert is_map(quote)
      assert Map.has_key?(quote, "symbol") or Map.has_key?(quote, "description")
    end

    test "get_quote surfaces 404 error" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/marketdata/NO_SUCH/quotes", "error_404.json", 404)

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.GetQuote.get_quote(client, "NO_SUCH")
    end
  end

  describe "OptionChain Builder" do
    test "builds a basic option chain request map" do
      chain =
        TDAmeritrade.OptionChain.new()
        |> TDAmeritrade.OptionChain.add_chain_key("symbol", "AAPL")
        |> TDAmeritrade.OptionChain.add_chain_key("contractType", "CALL")
        |> TDAmeritrade.OptionChain.add_chain_key("strikeCount", 3)

      map = TDAmeritrade.OptionChain.to_map(chain)

      assert map["symbol"] == "AAPL"
      assert map["contractType"] == "CALL"
      assert map["strikeCount"] == 3
    end
  end
end
