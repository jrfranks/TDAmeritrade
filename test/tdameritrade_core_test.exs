# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
# -

defmodule TDAmeritrade.CoreTest do
  use ExUnit.Case, async: true

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  describe "Client" do
    test "new/1 builds struct with defaults and overrides" do
      c = Client.new(access_token: "tok123", user: "me", account_id: "12345")
      assert c.access_token == "tok123"
      assert c.user == "me"
      assert c.account_id == "12345"
    end

    test "has_token?/1" do
      assert Client.has_token?(Client.new(access_token: "x"))
      refute Client.has_token?(Client.new(access_token: ""))
      refute Client.has_token?(Client.new())
    end

    test "auth_header/1" do
      assert {"Authorization", "Bearer abc"} = Client.auth_header(Client.new(access_token: "abc"))
      assert {"Authorization", "Bearer "} = Client.auth_header(Client.new())
    end
  end

  describe "Error" do
    test "struct and message" do
      e = %Error{status: 401, message: "unauthorized", body: %{"error" => "bad"}}
      assert e.status == 401
      assert e.message == "unauthorized"
    end
  end
end
