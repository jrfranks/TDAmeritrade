# TDAmeritrade Elixir Client

[![CI](https://github.com/jrfranks/TDAmeritrade/actions/workflows/ci.yml/badge.svg)](https://github.com/jrfranks/TDAmeritrade/actions/workflows/ci.yml)

A complete, self-contained Elixir implementation of the historical TD Ameritrade (now Schwab) REST and Streaming APIs.

This library preserves the full historical API surface as high-quality, maintainable Elixir code long after the original service was decommissioned. It is designed as a **fully runnable code demonstration and reference implementation**, proving correctness through an extensive automated test suite using [Bypass](https://github.com/PSPDFKit-labs/bypass) for hermetic HTTP mocking. No live credentials or network access are required.

## Features

- **Full REST Coverage** — All ~35 documented endpoints implemented (Market Data, Accounts, Orders, Transactions, Watchlists, Saved Orders, Preferences, User Principals, etc.).
- **Modern Streaming** — `TDAmeritrade.Stream.Real` (real WebSocket) and `TDAmeritrade.Stream.Offline` (hermetic simulator for tests/demos) with rich parsers and command builders.
- **Client-first Design** — `%TDAmeritrade.Client{}` + consistent error handling via `%TDAmeritrade.Error{}`.
- **Legacy Surface Preserved** — Old `use TDAmeritrade` macros still work (with deprecation warnings pointing to the modern API).
- **Exhaustive Tests** — Positive, negative, and value-extreme cases for every public function using local JSON fixtures.

## Installation

```elixir
def deps do
  [
    {:tdameritrade, "~> 0.2.0"}
  ]
end
```

## Quick Start (Modern API)

```elixir
# Create a client (token can come from anywhere)
client = TDAmeritrade.Client.new(access_token: "YOUR_ACCESS_TOKEN")

# Market Data
{:ok, quote} = TDAmeritrade.Rest.GetQuote.get_quote(client, "AAPL")
{:ok, history} = TDAmeritrade.Rest.GetPriceHistory.get_price_history(client, "AAPL", periodType: "day")

# Streaming (hermetic demo - no network)
{:ok, streamer} = TDAmeritrade.Stream.Offline.start_link()
TDAmeritrade.Stream.Offline.subscribe(streamer, "LEVELONE_EQUITY", "AAPL", "0,1,2,3", self())

# Push a recorded frame (in real usage the Real streamer receives live frames)
TDAmeritrade.Stream.Offline.push_frame(some_recorded_frame)

# Or run the full demo:
#   elixir -S mix run demo.exs
```

## Running the Tests

**`mix test.ci` is the command that verifies the library.** GitHub Actions runs the same alias on Elixir 1.15/OTP 26 and Elixir 1.17/OTP 27.

```bash
mix deps.get
mix test.ci
```

That runs format check, warnings-as-errors compile, and the hermetic suite. No live credentials or network access are required.

`mix test` runs the suite only (no format or compiler-warning gate). It covers Market Data, Accounts & Orders, Watchlists, Saved Orders, Preferences, and Streaming — positive, negative, and value-extreme cases for every public function, including both the modern `Rest.*` / `Stream.*` APIs and the legacy `use TDAmeritrade` surface.

## Legacy API (Deprecated)

The old flat functions (`TDAmeritrade.get_quote(...)`, `TDAmeritrade.admin()`, etc.) still exist for backward compatibility but emit deprecation warnings and delegate to the modern modules.

Prefer the explicit `TDAmeritrade.Rest.*` and `TDAmeritrade.Stream.*` modules for new code.

## Project Structure Highlights

- `lib/tdameritrade/rest/` — All 35 REST endpoint implementations
- `lib/tdameritrade/stream/real.ex` + `offline.ex` — Production and hermetic streaming
- `test/` — Clean, logical test groups exercising the full API surface

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for the full text.

The vendored Python reference client under `doc/td-ameritrade-python-api-0.3.5/` is also MIT-licensed; see that directory's `LICENSE` for its copyright notice.

---

**This library proves that a complete, documented, and exhaustively tested TD Ameritrade client can live on as a high-quality Elixir code artifact long after the original service has been decommissioned.**
