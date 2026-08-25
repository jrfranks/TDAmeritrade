# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade do
  @moduledoc """
  TD Ameritrade (historical) API client for Elixir.

  This library provides a complete, self-contained implementation of the
  retired TD Ameritrade REST and streaming APIs, designed for demonstration,
  education, and historical reference.

  ## Modern API (Recommended)

      client = TDAmeritrade.Client.new(access_token: "YOUR_TOKEN")

      # REST
      {:ok, quote} = TDAmeritrade.Rest.GetQuote.get_quote(client, "AAPL")

      # Streaming (hermetic demo)
      {:ok, streamer} = TDAmeritrade.Stream.Offline.start_link()
      TDAmeritrade.Stream.Offline.subscribe(streamer, "LEVELONE_EQUITY", "AAPL", "0,1,2,3", self())

  ## Legacy Compatibility

  The original flat API (`TDAmeritrade.get_quote/1`, `TDAmeritrade.admin/0`, etc.)
  is still supported via `use TDAmeritrade` for backward compatibility.
  New code should prefer the `TDAmeritrade.Rest.*` and `TDAmeritrade.Stream.*` modules.

  All legacy functions emit deprecation warnings pointing to the modern equivalents.
  """

  # Bring in the TDAmeritrade.* for of function name
  use TDAmeritrade.Connection
  use TDAmeritrade.Rest.CancelOrder
  use TDAmeritrade.Rest.CreateSavedOrder
  use TDAmeritrade.Rest.CreateWatchlist
  use TDAmeritrade.Rest.DeleteSavedOrder
  use TDAmeritrade.Rest.DeleteWatchlist
  use TDAmeritrade.Rest.GetAccount
  use TDAmeritrade.Rest.GetAccounts
  use TDAmeritrade.Rest.GetHoursForASingleMarket
  use TDAmeritrade.Rest.GetHoursForMultipleMarkets
  use TDAmeritrade.Rest.GetInstrument
  use TDAmeritrade.Rest.GetMovers
  use TDAmeritrade.Rest.GetOptionChain
  use TDAmeritrade.Rest.GetOrder
  use TDAmeritrade.Rest.GetOrdersByPath
  use TDAmeritrade.Rest.GetOrdersByQuery
  use TDAmeritrade.Rest.GetPreferences
  use TDAmeritrade.Rest.GetPriceHistory
  use TDAmeritrade.Rest.GetQuote
  use TDAmeritrade.Rest.GetQuotes
  use TDAmeritrade.Rest.GetSavedOrder
  use TDAmeritrade.Rest.GetSavedOrdersByPath
  use TDAmeritrade.Rest.GetStreamerSubscriptionKeys
  use TDAmeritrade.Rest.GetTransaction
  use TDAmeritrade.Rest.GetTransactions
  use TDAmeritrade.Rest.GetUserPrincipals
  use TDAmeritrade.Rest.GetWatchlist
  use TDAmeritrade.Rest.GetWatchlistsForMultipleAccounts
  use TDAmeritrade.Rest.GetWatchlistsForSingleAccount
  use TDAmeritrade.Rest.PlaceOrder
  use TDAmeritrade.Rest.ReplaceOrder
  use TDAmeritrade.Rest.ReplaceSavedOrder
  use TDAmeritrade.Rest.ReplaceWatchlist
  use TDAmeritrade.Rest.SearchInstruments
  use TDAmeritrade.Rest.UpdatePreferences
  use TDAmeritrade.Rest.UpdateWatchlist

  # High-level builders (new in this release)
  alias TDAmeritrade.Orders

  # Convenient top-level aliases for the most common advanced order helpers
  defdelegate order_market(leg), to: Orders.Strategies, as: :market
  defdelegate order_limit(leg, price), to: Orders.Strategies, as: :limit
  defdelegate order_stop(leg, stop_price), to: Orders.Strategies, as: :stop
  defdelegate order_stop_limit(leg, stop, limit), to: Orders.Strategies, as: :stop_limit

  defdelegate order_trailing_stop(leg, offset, type \\ :amount),
    to: Orders.Strategies,
    as: :trailing_stop

  defdelegate order_trailing_stop_limit(leg, trail, lim, type \\ :amount),
    to: Orders.Strategies,
    as: :trailing_stop_limit

  defdelegate order_market_on_close(leg), to: Orders.Strategies, as: :market_on_close
  defdelegate order_limit_on_close(leg, price), to: Orders.Strategies, as: :limit_on_close
  defdelegate bracket_order(primary, tp, sl), to: Orders.Strategies, as: :bracket
  defdelegate oco_order(leg1, leg2), to: Orders.Strategies, as: :oco
  defdelegate trigger_order(primary, child), to: Orders.Strategies, as: :trigger

  # Additional popular high-level helpers
  defdelegate covered_call(stock_leg, call_leg), to: Orders.Strategies, as: :covered_call
  defdelegate cash_secured_put(put_leg), to: Orders.Strategies, as: :cash_secured_put

  defdelegate iron_condor(short_put, long_put, short_call, long_call),
    to: Orders.Strategies,
    as: :iron_condor

  defdelegate bull_call_spread(buy, sell), to: Orders.Strategies, as: :bull_call_vertical_spread
  defdelegate bear_put_spread(buy, sell), to: Orders.Strategies, as: :bear_put_vertical_spread
  defdelegate call_butterfly(low, middle, high), to: Orders.Strategies, as: :call_butterfly
  defdelegate put_butterfly(high, middle, low), to: Orders.Strategies, as: :put_butterfly

  # Even more / "all" high-level helpers (market/limit on close, credit verticals, straddles, strangles, collar, calendar, diagonal, synthetics)
  defdelegate market_on_close(leg), to: Orders.Strategies, as: :market_on_close
  defdelegate limit_on_close(leg, price), to: Orders.Strategies, as: :limit_on_close
  defdelegate bear_call_spread(sell, buy), to: Orders.Strategies, as: :bear_call_vertical_spread
  defdelegate bull_put_spread(sell, buy), to: Orders.Strategies, as: :bull_put_vertical_spread
  defdelegate long_straddle(put, call), to: Orders.Strategies, as: :long_straddle
  defdelegate short_straddle(put, call), to: Orders.Strategies, as: :short_straddle
  defdelegate long_strangle(put, call), to: Orders.Strategies, as: :long_strangle
  defdelegate short_strangle(put, call), to: Orders.Strategies, as: :short_strangle
  defdelegate collar(stock, put, call), to: Orders.Strategies, as: :collar
  defdelegate calendar_spread(near, far), to: Orders.Strategies, as: :calendar_spread
  defdelegate diagonal_spread(near, far), to: Orders.Strategies, as: :diagonal_spread

  defdelegate synthetic_long_stock(long_call, short_put),
    to: Orders.Strategies,
    as: :synthetic_long_stock

  defdelegate synthetic_short_stock(short_call, long_put),
    to: Orders.Strategies,
    as: :synthetic_short_stock

  # ---------------------------------------------------------------------------
  # Legacy streaming surface (all deprecated — kept for backward compatibility)
  # ---------------------------------------------------------------------------
  use TDAmeritrade.Stream.AcctActivity
  use TDAmeritrade.Stream.Actives
  use TDAmeritrade.Stream.Admin
  use TDAmeritrade.Stream.Book
  use TDAmeritrade.Stream.Chart
  use TDAmeritrade.Stream.ChartHistory
  use TDAmeritrade.Stream.CommandFormat
  use TDAmeritrade.Stream.Data
  use TDAmeritrade.Stream.Introduction
  use TDAmeritrade.Stream.LevelOne
  use TDAmeritrade.Stream.News
  use TDAmeritrade.Stream.Quickstart
  use TDAmeritrade.Stream.StreamerProtocols
  use TDAmeritrade.Stream.Streamer_server
  use TDAmeritrade.Stream.Timesale
  use TDAmeritrade.Stream.Title

  def start() do
    TDAmeritrade.Connection.start_link()
  end

  def stop() do
    TDAmeritrade.Connection.stop()
  end
end
