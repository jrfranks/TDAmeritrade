# Python TD Ameritrade API vs Elixir Implementation – Gap Analysis

**Date**: 2026
**Reference**: td-ameritrade-python-api-0.3.5 (official reference client)
**Elixir library**: current state after full REST + streaming implementation + test refactoring

## Executive Summary

The Elixir library has successfully ported the **vast majority** of the TD Ameritrade REST surface (all 35+ documented endpoints) and provides a solid, generic streaming client.

However, the **Python reference library** offers a significantly richer **high-level developer experience** in one remaining area:

1. **Streaming convenience layer** — Python has ~20+ specific high-level subscribe methods. Elixir only offers a generic `subscribe(service, keys, fields)` (the underlying protocol is fully implemented and hermetic).

**Order & OptionChain builders** (previously missing) have been implemented in Elixir as `TDAmeritrade.Orders.*` + `TDAmeritrade.OptionChain` and now provide full parity with the Python fluent experience.

The legacy browser OAuth login flow that exists in Python was intentionally removed/stubbed in Elixir (modern token injection is the supported path).

## Detailed Gap Analysis

### 1. REST Endpoints – Mostly Complete

| Python Method                        | Elixir Equivalent                          | Status     | Notes |
|--------------------------------------|--------------------------------------------|------------|-------|
| get_quotes                           | `GetQuotes`                                | ✅ Full    |       |
| get_price_history                    | `GetPriceHistory`                          | ✅ Full    |       |
| search_instruments                   | `SearchInstruments`                        | ✅ Full    |       |
| get_instruments (by cusip)           | `GetInstrument`                            | ✅ Full    |       |
| get_market_hours                     | `GetHoursForASingleMarket` + `GetHoursForMultipleMarkets` | ✅ Full | Different naming |
| get_movers                           | `GetMovers`                                | ✅ Full    |       |
| get_options_chain                    | `GetOptionChain`                           | ✅ Full    |       |
| get_accounts / get_account           | `GetAccounts` / `GetAccount`               | ✅ Full    |       |
| get_transactions / get_transaction   | `GetTransactions` / `GetTransaction`       | ✅ Full    |       |
| get_preferences / update_preferences | `GetPreferences` / `UpdatePreferences`     | ✅ Full    |       |
| get_user_principals                  | `GetUserPrincipals`                        | ✅ Full    |       |
| get_streamer_subscription_keys       | `GetStreamerSubscriptionKeys`              | ✅ Full    |       |
| create_watchlist / get / delete / update / replace | Full CRUD modules | ✅ Full |       |
| get_watchlist_accounts               | `GetWatchlistsForSingleAccount` + `GetWatchlistsForMultipleAccounts` | ✅ Full |       |
| get_orders_path / get_orders_query / get_orders | `GetOrdersByPath` / `GetOrdersByQuery` / `GetOrder` | ✅ Full |       |
| place_order / cancel_order / modify_order | `PlaceOrder` / `CancelOrder` / `ReplaceOrder` | ✅ Full | "modify" = "replace" |
| get_saved_order / cancel / create    | Full saved order CRUD                      | ✅ Full    |       |

**Auth / Token methods** (login, oauth, grab_access_token, etc.) → Not replicated (intentional). Elixir uses token injection via `Auth.put_token/2`.

### 2. Streaming – Major Gap in Developer Experience

**Python (`TDStreamerClient`)** provides many high-level, strongly-typed subscribe methods:

- `quality_of_service(qos_level)`
- `chart(service, symbols, fields)`
- `actives(service, venue, duration)`
- `account_activity()`
- `chart_history_futures(...)`
- `level_one_quotes(symbols, fields)`
- `level_one_options(...)`, `level_one_futures(...)`, `level_one_forex(...)`, `level_one_futures_options(...)`
- `news_headline(symbols, fields)`
- `timesale(service, symbols, fields)`
- Many `level_two_*` variants (`level_two_quotes`, `level_two_options`, `level_two_nasdaq`, `level_two_total_view`, `_level_two_opra`, `_level_two_nyse`, `_level_two_futures_options`, `_level_two_futures`, `_level_two_forex`)
- Runtime helpers: `write_behavior(...)`, `stream(...)`, `close_logic(...)`

**Elixir current state**:
- `TDAmeritrade.Stream.Real.subscribe(streamer, service, keys, fields)` (and same on `Offline`)
- Low-level `Commands.build_subscribe_request/6`
- Full generic parsing via `Parsers`

**Status**: Partial / Lower-level only.

The generic API can do everything the Python high-level methods do, but there are **no convenience wrappers**. Users must know the exact service names and field numbers.

### 3. Order & Option Builders – Implemented

**Python**:
- `td.orders.Order` + `OrderLeg` – fluent builder for complex orders (including OCO, trigger, options, etc.).
- `td.option_chain.OptionChain` – builder for option chain requests.

**Elixir** (current):
- `TDAmeritrade.Orders.Order` + `TDAmeritrade.Orders.OrderLeg` — full fluent builder (new/ setters / add_leg / add_child_order_strategy / to_map).
- `TDAmeritrade.Orders.Strategies` — high-level constructors for bracket, iron_condor, butterfly, vertical spreads, collar, covered call, straddle/strangle, synthetic, calendar, diagonal, OCO, trigger, trailing stops, market/limit on close, etc.
- `TDAmeritrade.OptionChain` — simple builder for option chain request payloads (mirrors the Python experience).
- All builders produce plain maps compatible with `PlaceOrder`, `CreateSavedOrder`, `GetOptionChain`, etc.

**Status**: ✅ Complete (parity achieved).

### 4. Minor / Naming Differences

- `get_market_hours` → split into two modules in Elixir.
- `get_watchlist_accounts` → split into single/multiple in Elixir.
- `modify_order` → called `replace_order` in Elixir.
- Streaming service names and field handling are lower-level in Elixir.

## Recommendations & Proposed Changes

### High Value (Recommended to Implement)

1. **Streaming Convenience Layer** (`TDAmeritrade.Stream.Subscriptions` or methods on Real/Offline)
   - Add high-level functions mirroring Python:
     - `level_one_quotes(streamer, symbols, fields)`
     - `news_headline(...)`
     - `timesale(...)`
     - `level_two_quotes(...)` and other common level two variants
     - `quality_of_service(...)`
     - `chart(...)`, `actives(...)`, `account_activity(...)`, `chart_history_futures(...)`

   This would make the Elixir streaming experience feel much closer to the Python reference without losing the generic power.

2. **Order Builders** (`TDAmeritrade.Orders`) — ✅ **Completed**
   - `TDAmeritrade.Orders.Order` + `OrderLeg` + `Strategies` now provide the full fluent experience (including all the high-level strategy helpers).
   - Users can build complex orders exactly as recommended in earlier versions of this document and pass the result of `Order.to_map/1` (or `Strategies.*` output) to the REST endpoints.

3. **OptionChain Builder** — ✅ **Completed**
   - `TDAmeritrade.OptionChain` provides the requested builder.

### Lower Value / Not Recommended (for now)

- Re-implementing the full browser OAuth login flow (intentionally removed).
- Porting every single `level_two_*` variant (the generic subscribe already covers them).
- `write_behavior` / file logging helpers (different runtime model in Elixir).

### Documentation

- Add a new document `PYTHON_API_GAPS.md` (or section in README) with the table above so users coming from Python know exactly what is different.

## Conclusion

The Elixir library is **functionally complete** for REST + order/option-chain builders and provides a powerful generic streaming solution. The single remaining material gap for parity with the Python reference is **developer ergonomics** around high-level streaming subscriptions (the generic `subscribe` + `Commands` + `Parsers` already cover everything; convenience wrappers would just make it feel more like the Python `TDStreamerClient`).

The Order builders, Strategies, and OptionChain have been implemented and close that former gap completely.

---

*This report was generated as part of the final deep-dive task after the test suite and compilation were fully cleaned.*