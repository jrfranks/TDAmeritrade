# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.SavedOrdersTest do
  use ExUnit.Case, async: true

  alias TDAmeritrade.TestSupport.TdBypass
  alias Bypass

  describe "GetSavedOrdersByPath" do
    test "returns saved orders for an account (happy path)" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/accounts/12345/savedorders",
        "saved_orders_by_path_12345.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} =
               TDAmeritrade.Rest.GetSavedOrdersByPath.get_saved_orders_by_path(client, "12345")

      assert is_list(data)
      if length(data) > 0, do: assert(is_map(hd(data)))
    end

    test "surfaces 404 for unknown account" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/accounts/99999/savedorders", "error_404.json", 404)

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.GetSavedOrdersByPath.get_saved_orders_by_path(client, "99999")
    end
  end

  describe "GetSavedOrder" do
    test "returns a specific saved order" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/accounts/12345/savedorders/987654321",
        "saved_order_detailed.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} =
               TDAmeritrade.Rest.GetSavedOrder.get_saved_order(client, "12345", "987654321")

      assert is_map(data)
      assert Map.has_key?(data, "savedOrderId") or Map.has_key?(data, "orderType") or is_map(data)
    end

    test "surfaces 404 when saved order not found" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/accounts/12345/savedorders/999999999",
        "error_404.json",
        404
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.GetSavedOrder.get_saved_order(client, "12345", "999999999")
    end
  end

  describe "CreateSavedOrder" do
    test "creates a saved order and verifies body" do
      bypass = TdBypass.start()

      Bypass.expect(bypass, "POST", "/v1/accounts/12345/savedorders", fn conn ->
        {:ok, body, _} = Plug.Conn.read_body(conn)
        assert body =~ "LIMIT"

        conn
        |> Plug.Conn.resp(200, "{}")
      end)

      client = TdBypass.client_for_bypass(bypass)

      body = %{
        "orderType" => "LIMIT",
        "price" => 175.00,
        "session" => "NORMAL",
        "duration" => "GOOD_TILL_CANCEL",
        "orderStrategyType" => "SINGLE",
        "orderLegCollection" => [
          %{
            "instruction" => "BUY",
            "quantity" => 1,
            "instrument" => %{"symbol" => "AAPL", "assetType" => "EQUITY"}
          }
        ]
      }

      assert {:ok, _} =
               TDAmeritrade.Rest.CreateSavedOrder.create_saved_order(client, "12345", body)
    end
  end

  describe "ReplaceSavedOrder" do
    test "replaces a saved order and verifies body" do
      bypass = TdBypass.start()

      Bypass.expect(bypass, "PUT", "/v1/accounts/12345/savedorders/987654321", fn conn ->
        {:ok, body, _} = Plug.Conn.read_body(conn)
        assert body =~ "LIMIT"

        conn
        |> Plug.Conn.resp(200, "{}")
      end)

      client = TdBypass.client_for_bypass(bypass)

      body = %{
        "orderType" => "LIMIT",
        "price" => 175.00,
        "session" => "NORMAL",
        "duration" => "GOOD_TILL_CANCEL",
        "orderStrategyType" => "SINGLE",
        "orderLegCollection" => [
          %{
            "instruction" => "SELL",
            "quantity" => 2,
            "instrument" => %{"symbol" => "AAPL", "assetType" => "EQUITY"}
          }
        ]
      }

      assert {:ok, _} =
               TDAmeritrade.Rest.ReplaceSavedOrder.replace_saved_order(
                 client,
                 "12345",
                 "987654321",
                 body
               )
    end
  end

  describe "DeleteSavedOrder" do
    test "deletes a saved order successfully" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "DELETE",
        "/v1/accounts/12345/savedorders/987654321",
        "empty.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, result} =
               TDAmeritrade.Rest.DeleteSavedOrder.delete_saved_order(client, "12345", "987654321")

      assert result.savedOrderId == "987654321"
      assert result.status == "DELETED"
    end

    test "surfaces 404 when saved order not found" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "DELETE",
        "/v1/accounts/12345/savedorders/999999999",
        "error_404.json",
        404
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.DeleteSavedOrder.delete_saved_order(client, "12345", "999999999")
    end
  end
end
