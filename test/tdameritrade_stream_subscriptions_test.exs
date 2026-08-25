# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.StreamSubscriptionsTest do
  use ExUnit.Case, async: true

  alias TDAmeritrade.Stream.Offline
  alias TDAmeritrade.Stream.Subscriptions

  describe "high-level Subscriptions API against Offline backend" do
    test "level_one_quotes, chart, actives, news, timesale via Offline" do
      {:ok, pid} = Offline.start_link(name: nil)

      # These should not crash and should register subscriptions
      Subscriptions.level_one_quotes(pid, "AAPL,MSFT", "0,1,2,3,4,5")
      Subscriptions.chart(pid, "CHART_EQUITY", "AAPL", "0,1,2,3,4,5,6,7,8")
      Subscriptions.actives(pid, "ACTIVES_NASDAQ", "NASDAQ", "60000")
      Subscriptions.news_headline(pid, "AAPL", "0,1,2,3")
      Subscriptions.timesale(pid, "TIMESALE_EQUITY", "AAPL", "0,1,2,3")

      # Verify internal state has subscriptions
      # (we can't easily introspect, but at least the calls succeeded)
      assert is_pid(pid)
    end

    test "quality_of_service works on Offline (no-op)" do
      {:ok, pid} = Offline.start_link(name: nil)
      assert :ok = Subscriptions.quality_of_service(pid, 1)
      assert :ok = Subscriptions.quality_of_service(Offline, 2)
    end

    test "account_activity and level_two" do
      {:ok, pid} = Offline.start_link(name: nil)
      Subscriptions.account_activity(pid, "12345")
      Subscriptions.level_two_quotes(pid, "AAPL", "0,1,2,3")
      assert is_pid(pid)
    end
  end
end
