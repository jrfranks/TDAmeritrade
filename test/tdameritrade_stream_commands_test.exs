# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
# -

defmodule TDAmeritrade.StreamCommandsTest do
  use ExUnit.Case, async: true

  alias TDAmeritrade.Stream.Commands

  describe "build_request/6" do
    test "constructs a well-formed request map" do
      req =
        Commands.build_request("QUOTE", "SUBS", 42, "12345", "MYAPP", %{
          "keys" => "AAPL",
          "fields" => "0,1,2"
        })

      assert req["service"] == "QUOTE"
      assert req["command"] == "SUBS"
      assert req["requestid"] == 42
      assert req["account"] == "12345"
      assert req["source"] == "MYAPP"
      assert req["parameters"]["keys"] == "AAPL"
    end
  end

  describe "build_login_request/4" do
    test "builds a proper ADMIN LOGIN request" do
      creds = %{
        "token" => "abc123",
        "credential" => "encoded-cred",
        "usergroup" => "GROUP",
        "accesslevel" => "ACCT",
        "timestamp" => 1_700_000_000_000,
        "acl" => "aclval"
      }

      req = Commands.build_login_request(1, "12345", "MYAPP", creds)

      assert req["service"] == "ADMIN"
      assert req["command"] == "LOGIN"
      assert req["requestid"] == 1
      assert req["parameters"]["token"] == "abc123"
      assert req["parameters"]["authorized"] == "Y"
    end
  end

  describe "build_qos_request/4" do
    test "builds a QOS ADMIN request with integer level" do
      req = Commands.build_qos_request(5, "12345", "MYAPP", 2)

      assert req["service"] == "ADMIN"
      assert req["command"] == "QOS"
      assert req["parameters"]["qoslevel"] == 2
    end
  end

  describe "build_subscribe_request/6 and build_unsubscribe_request/5" do
    test "subscribe request has correct shape" do
      req =
        Commands.build_subscribe_request(
          "LEVELONE_EQUITY",
          10,
          "12345",
          "APP",
          "AAPL,MSFT",
          "0,1,2,3,4,5"
        )

      assert req["service"] == "LEVELONE_EQUITY"
      assert req["command"] == "SUBS"
      assert req["parameters"]["keys"] == "AAPL,MSFT"
      assert req["parameters"]["fields"] == "0,1,2,3,4,5"
    end

    test "unsubscribe request omits fields" do
      req = Commands.build_unsubscribe_request("CHART_FUTURES", 11, "12345", "APP", "/ES")

      assert req["command"] == "UNSUBS"
      assert req["parameters"]["keys"] == "/ES"
      refute Map.has_key?(req["parameters"], "fields")
    end
  end

  describe "wrap_requests/1" do
    test "wraps a list into the top-level requests envelope" do
      wrapped = Commands.wrap_requests([%{"service" => "ADMIN"}])

      assert wrapped == %{"requests" => [%{"service" => "ADMIN"}]}
    end
  end

  describe "prepare_streamer_credentials/1" do
    test "extracts and normalizes fields from a realistic userPrincipals response" do
      principals = %{
        "accounts" => [
          %{
            "accountId" => "12345",
            "company" => "MYCOMPANY",
            "segment" => "MYSEG",
            "accountCdDomainId" => "A123"
          }
        ],
        "streamerInfo" => %{
          "token" => "dummy-token-value",
          "tokenTimestamp" => "2024-01-01T10:00:00Z",
          "userGroup" => "MYGROUP",
          "accessLevel" => "ACCT",
          "appId" => "MYAPP",
          "acl" => "aclval"
        }
      }

      creds = Commands.prepare_streamer_credentials(principals)

      assert creds["userid"] == "12345"
      assert creds["token"] == "dummy-token-value"
      assert creds["company"] == "MYCOMPANY"
      assert creds["timestamp"] > 0
      assert creds["authorized"] == "Y"
    end

    test "handles missing streamerInfo gracefully" do
      creds = Commands.prepare_streamer_credentials(%{"accounts" => [%{"accountId" => "999"}]})

      assert creds["userid"] == "999"
      assert creds["timestamp"] == 0
    end
  end

  describe "build_login_frame/2" do
    test "produces a complete LOGIN frame ready to be JSON-encoded" do
      principals = %{
        "accounts" => [%{"accountId" => "12345"}],
        "streamerInfo" => %{
          "token" => "tok",
          "tokenTimestamp" => "2024-01-01T10:00:00Z",
          "appId" => "APP"
        }
      }

      frame = Commands.build_login_frame(principals, 0)

      assert %{"requests" => [req]} = frame
      assert req["service"] == "ADMIN"
      assert req["command"] == "LOGIN"
      assert is_binary(req["parameters"]["credential"])
      assert String.contains?(req["parameters"]["credential"], "token=")
    end
  end
end
