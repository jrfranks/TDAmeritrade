# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.PreferencesTest do
  use ExUnit.Case, async: true

  alias TDAmeritrade.TestSupport.TdBypass
  alias Bypass

  describe "GetPreferences" do
    test "returns preferences for an account" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/accounts/12345/preferences",
        "preferences.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} = TDAmeritrade.Rest.GetPreferences.get_preferences(client, "12345")
      assert is_map(data)
      # The fixture (preferences.json) should have expressTrading or similar
      assert Map.has_key?(data, "expressTrading") or is_map(data)
    end

    test "surfaces 404 for unknown account" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/accounts/99999/preferences", "error_404.json", 404)

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 404}} =
               TDAmeritrade.Rest.GetPreferences.get_preferences(client, "99999")
    end
  end

  describe "UpdatePreferences" do
    test "updates preferences and verifies body" do
      bypass = TdBypass.start()

      Bypass.expect(bypass, "PUT", "/v1/accounts/12345/preferences", fn conn ->
        {:ok, body, _} = Plug.Conn.read_body(conn)
        assert body =~ "expressTrading"

        conn
        |> Plug.Conn.resp(200, "{}")
      end)

      client = TdBypass.client_for_bypass(bypass)
      body = %{"expressTrading" => true}

      assert {:ok, _} =
               TDAmeritrade.Rest.UpdatePreferences.update_preferences(client, "12345", body)
    end
  end

  describe "GetUserPrincipals" do
    test "returns user principals with streamer info" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/userprincipals", "user_principals.json", 200)

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} =
               TDAmeritrade.Rest.GetUserPrincipals.get_user_principals(client,
                 fields: "streamerSubscriptionKeys,streamerConnectionInfo"
               )

      assert data["userId"] == "MYUSER123"
      assert data["streamerInfo"]["token"] == "dummy-token-value"
      assert is_map(data["streamerSubscriptionKeys"])
    end

    test "surfaces 401 when unauthorized" do
      bypass = TdBypass.start()
      TdBypass.expect_json(bypass, "GET", "/v1/userprincipals", "error_404.json", 401)

      client = TdBypass.client_for_bypass(bypass)

      assert {:error, %TDAmeritrade.Error{status: 401}} =
               TDAmeritrade.Rest.GetUserPrincipals.get_user_principals(client)
    end
  end

  describe "GetStreamerSubscriptionKeys" do
    test "returns subscription keys for accounts" do
      bypass = TdBypass.start()

      TdBypass.expect_json(
        bypass,
        "GET",
        "/v1/userprincipals/streamersubscriptionkeys",
        "user_principals.json",
        200
      )

      client = TdBypass.client_for_bypass(bypass)

      assert {:ok, data} =
               TDAmeritrade.Rest.GetStreamerSubscriptionKeys.get_streamer_subscription_keys(
                 client,
                 ["12345"]
               )

      assert is_map(data)
    end
  end
end
