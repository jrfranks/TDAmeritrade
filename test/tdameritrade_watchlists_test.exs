# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.WatchlistsTest do
  use ExUnit.Case, async: true

  alias TDAmeritrade.TestSupport.TdBypass
  alias Bypass

  describe "GetWatchlistsForSingleAccount" do
    test "returns watchlists for an account" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/accounts/12345/watchlists",
        "watchlists_single_account.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} =
               TDAmeritrade.Rest.GetWatchlistsForSingleAccount.get_watchlists_for_single_account(
                 client,
                 "12345"
               )

      assert is_list(data)
    end

    test "surfaces 404 for unknown account" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/accounts/99999/watchlists", "error_404.json", 404)

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.GetWatchlistsForSingleAccount.get_watchlists_for_single_account(
                 client,
                 "99999"
               )
    end
  end

  describe "GetWatchlistsForMultipleAccounts" do
    test "returns watchlists across accounts" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/accounts/watchlists",
        "watchlists_single_account.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} =
               TDAmeritrade.Rest.GetWatchlistsForMultipleAccounts.get_watchlists_for_multiple_accounts(
                 client
               )

      assert is_list(data)
      if length(data) > 0, do: assert is_map(hd(data))
    end
  end

  describe "GetWatchlist" do
    test "returns a specific watchlist" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/accounts/12345/watchlists/123456789",
        "watchlist_detailed.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} =
               TDAmeritrade.Rest.GetWatchlist.get_watchlist(client, "12345", "123456789")

      assert is_map(data)
    end

    test "surfaces 404 when watchlist not found" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/accounts/12345/watchlists/999999999",
        "error_404.json",
        404
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.GetWatchlist.get_watchlist(client, "12345", "999999999")
    end
  end

  describe "CreateWatchlist" do
    test "creates a watchlist and verifies body" do
      bypass = TdBypass.start()

      Bypass.expect(bypass, "POST", "/v1/accounts/12345/watchlists", fn conn ->
        {:ok, body, _} = Plug.Conn.read_body(conn)
        assert body =~ "My New Watchlist"

        conn
        |> Plug.Conn.resp(200, "{}")
      end)

      client = TdBypass.client_for_bypass(bypass)
      body = %{"name" => "My New Watchlist", "watchlistItems" => []}

      assert {:ok, _} = TDAmeritrade.Rest.CreateWatchlist.create_watchlist(client, "12345", body)
    end
  end

  describe "ReplaceWatchlist" do
    test "replaces a watchlist" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "PUT",
        "/v1/accounts/12345/watchlists/123456789",
        "empty.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)
      body = %{"name" => "Replaced Watchlist", "watchlistItems" => []}

      assert {:ok, _} =
               TDAmeritrade.Rest.ReplaceWatchlist.replace_watchlist(
                 client,
                 "12345",
                 "123456789",
                 body
               )
    end
  end

  describe "UpdateWatchlist" do
    test "updates a watchlist" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "PATCH",
        "/v1/accounts/12345/watchlists/123456789",
        "empty.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)
      body = %{"name" => "Renamed Watchlist"}

      assert {:ok, _} =
               TDAmeritrade.Rest.UpdateWatchlist.update_watchlist(
                 client,
                 "12345",
                 "123456789",
                 body
               )
    end
  end

  describe "DeleteWatchlist" do
    test "deletes a watchlist successfully" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "DELETE",
        "/v1/accounts/12345/watchlists/123456789",
        "empty.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, result} =
               TDAmeritrade.Rest.DeleteWatchlist.delete_watchlist(client, "12345", "123456789")

      assert result.watchlistId == "123456789"
      assert result.status == "DELETED"
    end

    test "surfaces 404 when watchlist not found" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "DELETE",
        "/v1/accounts/12345/watchlists/999999999",
        "error_404.json",
        404
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.DeleteWatchlist.delete_watchlist(client, "12345", "999999999")
    end
  end
end
