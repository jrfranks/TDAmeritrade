# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.StreamOfflineTest do
  use ExUnit.Case, async: true

  alias TDAmeritrade.Stream.Offline

  # Reuse the exact canonical frames from the parser tests
  @login_success_raw %{
    "response" => [
      %{
        "service" => "ADMIN",
        "requestid" => "1",
        "command" => "LOGIN",
        "timestamp" => 1_400_607_506_478,
        "content" => %{"code" => 0, "msg" => "02-1"}
      }
    ]
  }

  @login_denied_raw %{
    "response" => [
      %{
        "service" => "ADMIN",
        "requestid" => "1",
        "command" => "LOGIN",
        "timestamp" => 1_400_615_207_643,
        "content" => %{"code" => 3, "msg" => "Login Denied."}
      }
    ]
  }

  describe "ADMIN LOGIN reaction (deeper parser integration)" do
    test "emits {:tda_stream_login, :success, ...} and updates status on successful LOGIN frame" do
      {:ok, pid} = Offline.start_link(name: nil)

      Offline.subscribe(pid, "ADMIN", "", [], self())
      Offline.push_frame(pid, @login_success_raw)

      assert_receive {:tda_stream_login, :success, content}
      assert content.success == true
      assert content.code == 0
      assert content.msg == "02-1"
      assert content.reason == nil

      assert Offline.login_status(pid) == {:success, "02-1"}
    end

    test "emits {:tda_stream_login, :denied, ...} and updates status on denied LOGIN frame" do
      {:ok, pid} = Offline.start_link(name: nil)

      Offline.subscribe(pid, "ADMIN", "", [], self())
      Offline.push_frame(pid, @login_denied_raw)

      assert_receive {:tda_stream_login, :denied, content}
      assert content.success == false
      assert content.code == 3
      assert content.msg == "Login Denied."
      assert content.reason == "Login Denied."

      assert Offline.login_status(pid) == {:denied, "Login Denied."}
    end
  end

  describe "normal data delivery still works" do
    test "QUOTE frames are still delivered as {:tda_stream, service, content}" do
      quote_frame = %{
        "data" => [
          %{
            "service" => "QUOTE",
            "timestamp" => 1_402_072_133_226,
            "command" => "SUBS",
            "content" => [
              %{"1" => 41.41, "2" => 41.42, "3" => 41.42, "key" => "MSFT", "delayed" => false}
            ]
          }
        ]
      }

      {:ok, pid} = Offline.start_link(name: nil)
      Offline.subscribe(pid, "QUOTE", "MSFT", "0,1,2,3", self())
      Offline.push_frame(pid, quote_frame)

      assert_receive {:tda_stream, "QUOTE", [item]}
      assert item.bid_price == 41.41
      assert item.ask_price == 41.42
      assert item.key == "MSFT"
    end
  end
end
