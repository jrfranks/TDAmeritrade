# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
# -

defmodule TDAmeritrade.StreamRealTest do
  use ExUnit.Case, async: true

  alias TDAmeritrade.Stream.Commands

  @principals Poison.decode!(File.read!("test/fixtures/td_responses/user_principals.json"))

  describe "credential preparation for real WebSocket LOGIN" do
    test "prepare_streamer_credentials produces the expected shape and integer timestamp" do
      creds = Commands.prepare_streamer_credentials(@principals)

      assert creds["userid"] == "12345"
      assert creds["token"] == "dummy-token-value"
      assert creds["company"] == "MYCOMPANY"
      assert creds["appid"] == "MYAPPID"
      assert is_integer(creds["timestamp"])
      assert creds["timestamp"] > 0
      assert creds["authorized"] == "Y"
    end

    test "build_login_frame produces a valid wrapped LOGIN request" do
      frame = Commands.build_login_frame(@principals, 0)

      assert %{"requests" => [login]} = frame
      assert login["service"] == "ADMIN"
      assert login["command"] == "LOGIN"
      assert login["account"] == "12345"

      params = login["parameters"]
      assert params["version"] == "1.0"
      assert is_binary(params["credential"])
      assert String.contains?(params["credential"], "token=")
      assert params["token"] == "dummy-token-value"
    end
  end
end
