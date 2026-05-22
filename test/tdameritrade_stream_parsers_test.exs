# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
# -

defmodule TDAmeritrade.StreamParsersTest do
  use ExUnit.Case, async: true

  alias TDAmeritrade.Stream.Parsers

  describe "ADMIN responses (LOGIN)" do
    test "parses successful LOGIN response" do
      raw = %{
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

      parsed = Parsers.parse_message(raw)

      assert [%{"service" => "ADMIN", "command" => "LOGIN", "content" => content}] = parsed["response"]

      assert content.success == true
      assert content.code == 0
      assert content.msg == "02-1"
      assert content.reason == nil
    end

    test "parses LOGIN denied response" do
      raw = %{
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

      parsed = Parsers.parse_message(raw)

      assert [%{"service" => "ADMIN", "command" => "LOGIN", "content" => content}] = parsed["response"]

      assert content.success == false
      assert content.code == 3
      assert content.msg == "Login Denied."
      assert content.reason == "Login Denied."
    end
  end

  describe "LEVELONE / QUOTE parsing" do
    test "parses a basic QUOTE content item" do
      raw = %{
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

      parsed = Parsers.parse_message(raw)

      assert [item] = hd(parsed["data"])["content"]
      assert item.bid_price == 41.41
      assert item.ask_price == 41.42
      assert item.last_price == 41.42
      assert item.key == "MSFT"
    end
  end

  describe "CHART parsing" do
    test "parses a basic CHART content item" do
      raw = %{
        "data" => [
          %{
            "service" => "CHART_FUTURES",
            "content" => [
              %{
                "0" => "/ES",
                "1" => 1_402_059_300_000,
                "2" => 1942.5,
                "3" => 1943.0,
                "4" => 1942.5,
                "5" => 1943.0,
                "6" => 2202
              }
            ]
          }
        ]
      }

      parsed = Parsers.parse_message(raw)

      assert [item] = hd(parsed["data"])["content"]
      assert item.key == "/ES"
      assert item.chart_time == 1_402_059_300_000
      assert item.open_price == 1942.5
      assert item.high_price == 1943.0
    end
  end

  describe "TIMESALE parsing" do
    test "parses a basic TIMESALE content item" do
      raw = %{
        "data" => [
          %{
            "service" => "TIMESALE_EQUITY",
            "content" => [
              %{"0" => "AAPL", "1" => 1_402_059_321_000, "2" => 178.46, "3" => 100, "4" => 12345}
            ]
          }
        ]
      }

      parsed = Parsers.parse_message(raw)

      assert [item] = hd(parsed["data"])["content"]
      assert item.key == "AAPL"
      assert item.last_price == 178.46
      assert item.last_size == 100
    end
  end

  describe "ADMIN QOS and generic responses" do
    test "parses QOS response" do
      raw = %{
        "response" => [
          %{
            "service" => "ADMIN",
            "command" => "QOS",
            "content" => %{"code" => 0, "msg" => "QOS OK"}
          }
        ]
      }

      parsed = Parsers.parse_message(raw)
      assert hd(parsed["response"])["content"].code == 0
    end
  end

  describe "snapshot and notify paths" do
    test "passes through snapshot and notify shapes" do
      snap = %{"snapshot" => [%{"service" => "QUOTE", "content" => []}]}
      assert Parsers.parse_message(snap)["snapshot"]

      notify = %{"notify" => [%{"service" => "ADMIN", "content" => %{}}]}
      assert Parsers.parse_message(notify)["notify"]
    end
  end

  describe "generic fallback for unknown services" do
    test "converts numeric string keys to atoms for unknown list content" do
      raw = %{
        "data" => [
          %{"service" => "UNKNOWN_SERVICE", "content" => [%{"0" => "x", "99" => 1}]}
        ]
      }

      parsed = Parsers.parse_message(raw)
      item = hd(hd(parsed["data"])["content"])
      assert Map.has_key?(item, :"0")
      assert item[:"99"] == 1
    end
  end

  describe "error / non-map input" do
    test "returns non-map input unchanged" do
      assert Parsers.parse_message("hello") == "hello"
      assert Parsers.parse_message(nil) == nil
    end
  end
end
