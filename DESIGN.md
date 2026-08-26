<!--
Copyright (c) 2022-2026 SvelteSoft Inc.
Licensed under the MIT License. See LICENSE for the full text.
-->

# TDAmeritrade Elixir Client — Design Document

**Version**: 0.2.0 (current as of 2026)  
**Status**: Retrospective architecture and design description of the as-built library  
**Related files**: [README.md](README.md), [PYTHON_API_GAPS.md](PYTHON_API_GAPS.md), [mix.exs](mix.exs), [LICENSE](LICENSE)

This document describes the architecture, implementation approach, and explicit design decisions in the TDAmeritrade Elixir client. It is intended for maintainers, contributors, and anyone studying how to build a self-contained, hermetic reference implementation of a retired external API in Elixir.

---

## 1. Introduction and Purpose

The TDAmeritrade Elixir client is a complete, self-contained implementation of the historical TD Ameritrade (now part of Schwab) REST and WebSocket streaming APIs. The original service has been decommissioned; this library preserves the full API surface as high-quality, maintainable Elixir code for demonstration, education, and historical reference.

Primary goals:
- Provide a **fully runnable code demonstration and reference implementation** that requires no live credentials or network access.
- Make `mix test.ci` the command that validates the library (format, warnings-as-errors, and the hermetic suite).
- Support both a clean modern API (`TDAmeritrade.Client` + `TDAmeritrade.Rest.*` / `TDAmeritrade.Stream.*`) and a backward-compatible legacy surface via `use TDAmeritrade`.
- Achieve functional parity with the reference Python client (`td-ameritrade-python-api-0.3.5`, vendored under `doc/`) for REST endpoints and order/option-chain builders, while adapting to Elixir idioms.
- Enable long-term archival of the API as a code artifact.

Non-goals:
- Serve as a production client for live Schwab APIs (post-decommissioning).
- Replicate every high-level convenience method from the Python `TDStreamerClient` (the generic subscribe interface + parsers cover the protocol; ergonomic wrappers are partial).
- Support the legacy browser-based OAuth login flow (intentionally replaced by explicit token injection).

The library depends on a small set of focused packages (`httpoison`, `poison`, `websockex`, `oauth2`, `bypass` for tests) and enforces hermetic testing via Bypass mock servers and an offline streaming simulator.

---

## 2. High-Level Architecture

The system is organized into two primary surfaces (REST and Streaming) with a shared modern/legacy compatibility layer and supporting builder modules.

```
Callers
├── Modern (recommended)
│   ├── TDAmeritrade.Client.new(access_token: "...")
│   ├── TDAmeritrade.Rest.GetQuote.get_quote(client, "AAPL")
│   └── TDAmeritrade.Stream.{Real,Offline}.subscribe(...)
│
└── Legacy (via `use TDAmeritrade`)
    ├── TDAmeritrade.get_quote("default", "AAPL")  (deprecated, emits warning)
    └── TDAmeritrade.Stream.create() / etc.

Core Layers
├── TDAmeritrade.Rest.* (35 endpoint modules)  ──→  TDAmeritrade.Rest (normalize + verbs)
├── TDAmeritrade.Stream.{Real, Offline}        ──→  shared Commands + Parsers + Subscriptions
│
├── TDAmeritrade.Connection  (dual dispatch: Client→HTTPoison | binary→OAuth2.Client)
├── TDAmeritrade.Error       (standardized error struct + from_connection_result)
├── TDAmeritrade.Auth        (Agent for legacy token storage)
│
└── External: HTTPoison, Poison, WebSockex, OAuth2, Bypass (test only)
```

Cross-cutting:
- `TDAmeritrade.Orders` + `TDAmeritrade.OptionChain` — fluent builders producing plain maps for order placement.
- `TDAmeritrade.Types.*` — pure documentation / schema modules (ignored by coverage).
- Numerous thin `TDAmeritrade.Stream.*` facade modules — exist only for `use` + historical docs (coverage-ignored).

Two major implementation domains:
- **REST**: One dedicated module per endpoint under `lib/tdameritrade/rest/`.
- **Streaming**: Dual implementations (`Real` for live WebSocket, `Offline` for hermetic simulation) sharing the protocol logic in `Commands` and `Parsers`.

---

## 3. Core Components

### 3.1 TDAmeritrade.Client

`lib/tdameritrade/client.ex`

A lightweight, immutable struct holding session state:

```elixir
defstruct access_token: nil, user: nil, account_id: nil, base_url: nil
```

- Primary constructor: `TDAmeritrade.Client.new(access_token: "token", base_url: "...")`.
- `base_url` override is the key enabler for hermetic Bypass tests (points at `http://localhost:port`).
- `auth_header/1` produces the Bearer header for modern calls.
- In normal usage an OAuth access token is supplied; for the self-contained demo the token is passed explicitly.

### 3.2 TDAmeritrade.Connection

`lib/tdameritrade/connection.ex`

Low-level HTTP transport with **dual dispatch**:

- When the target is a `%Client{}` with `base_url` → direct `HTTPoison.request` (Bypass path).
- Otherwise (legacy binary user) → `OAuth2.Client` machinery via `TDAmeritrade.Auth.client/1`.

The `prepare/3` function resolves the full URL against `@default_base` or the client's `base_url` and injects the Authorization header for Client cases.

A `__using__` macro provides the old flat `Connection.get(user, url, ...)` surface for legacy code.

This design allows the same higher-level code to work in both hermetic test mode and legacy multi-user mode without branching at the call sites.

### 3.3 TDAmeritrade.Rest (shared) + 35 Endpoint Modules

`lib/tdameritrade/rest.ex` + `lib/tdameritrade/rest/*.ex`

The `Rest` module exists **"purely to eliminate the previous 30× duplication of `normalize_client/1` across every REST implementation."** (rest.ex:10-18)

Core helper:

```elixir
def normalize(%Client{} = c), do: c
def normalize(user) when is_binary(user), do: Client.new(user: user)
def normalize(_), do: Client.new()

def get(client_or_user, path), do: ... |> Error.from_connection_result()
# similar for post/put/patch/delete
```

Every endpoint module follows an **identical structural pattern** (observed uniformly across all 35 files):

- `@moduledoc` describing the modern surface and recommending it over legacy.
- `alias Client` + `alias Error`.
- `@spec` on the primary function accepting `Client.t() | binary()`.
- Primary function(s) that build the TD API path (with optional query-string handling from `opts`) and delegate to `TDAmeritrade.Rest.get/post/...`.
- Arity-0 fallback returning `{:error, Error.new_client_error(...)}`.
- `defmacro __using__(_) do ... @deprecated "Use TDAmeritrade.Rest.XXX..." ...` that synthesizes a Client from `TDAmeritrade.Auth` under the hard-coded `"default"` user and delegates.

Variations are minor and localized:
- Most use the high-level `Rest.*` verbs.
- Order-related modules (`place_order.ex`, `replace_order.ex`) call `normalize/1` + `Connection.*` directly to inspect `status_code: 201` and `Location` headers, then return synthetic `%{orderId: ..., status: "CREATED"}` maps.
- Query-string construction is repeated locally in several modules (not extracted).

**Why one module per endpoint?**  
It centralizes only the cross-cutting concerns (auth normalization, error wrapping, legacy bridging) while letting each endpoint own its URL logic, documentation, specs, examples, and any special response handling. Adding an endpoint is copy-paste + customize; changing auth/error behavior touches only `rest.ex`. Each module remains independently testable.

Full list of 35 modules is enumerated in the explorer report for the REST layer (cancel_order through update_watchlist).

### 3.4 TDAmeritrade.Error

`lib/tdameritrade/error.ex`

Replaces previous inconsistent `{:error, term()}` returns with a single struct:

```elixir
defstruct [:status, :body, :reason, :message]
```

Constructors for HTTP status, transport errors, JSON decode failures, and client-side validation errors.

`from_connection_result/1` is the single point that turns `HTTPoison` + `Poison` outcomes into the standardized `{:ok, map()} | {:error, %Error{}}` shape used everywhere above the transport layer.

### 3.5 Streaming Subsystem

`lib/tdameritrade/stream/{real,offline,commands,parsers,subscriptions,...}.ex` and legacy facades.

#### Core Runtime

- **Real** (`real.ex`): `GenServer` that opens a `wss://` connection via `WebSockex`, performs the documented ADMIN LOGIN handshake immediately on init, maintains a pending-subscription queue, and flushes subscriptions once LOGIN succeeds. Uses an inner `SocketHandler` (coverage-ignored) to forward frames.
- **Offline** (`offline.ex`): `GenServer` (nameable or anonymous) that never touches the network. `push_frame(server, json_or_map)` injects a pre-recorded frame; the same parse-and-deliver logic runs as in Real.

Both expose **identical public APIs and emit identical message shapes**:

- `subscribe(server, service, keys, fields, subscriber)`
- `{:tda_stream, service, parsed_content}` to subscribers
- Special `{:tda_stream_login, :success | :denied, ...}` for ADMIN subscribers
- `login_status/1`, `quality_of_service/2`, etc.

#### Shared Protocol Logic (guarantees parity)

- **Commands** (`commands.ex`): Pure functions that build the exact JSON request frames required by the TD streaming protocol, including `prepare_streamer_credentials/1` (converts the ISO8601 `tokenTimestamp` from user principals into Unix milliseconds) and `build_login_frame/2`.
- **Parsers** (`parsers.ex`): `parse_message/1` dispatches on top-level keys (`response`, `data`, `notify`, `snapshot`). Per-service maps convert the compact numeric field IDs (e.g. `"0"` → `:symbol`, `"1"` → `:bid_price`) into friendly atoms. ADMIN responses receive extra shaping for the high-level login events.
- **Subscriptions** (`subscriptions.ex`): Growing set of higher-level wrappers around the generic `subscribe` (level_one_equity, chart_equity, actives, news, timesale, account_activity, qos, etc.). Provides partial parity with the Python convenience layer.

#### Legacy / Doc Facades

Many thin modules under `stream/` (`level_one.ex`, `chart.ex`, `admin.ex`, `acct_activity.ex`, ... plus `legacy.ex`, `introduction.ex`, etc.) contain only `@moduledoc` historical text and `use TDAmeritrade.Stream.Legacy` delegation. They exist solely for the `use TDAmeritrade` surface and documentation. They are explicitly excluded from coverage (see mix.exs).

#### Why Dual Implementations?

The Offline simulator allows the entire streaming surface (including login handshake, parsing, subscription lifecycle, and message delivery) to be exercised in unit tests and the `demo.exs` with zero network dependency and fully reproducible frames. Real provides the production path. Because both delegate to the same `Parsers` and `Commands`, the delivered data contract is guaranteed identical.

### 3.6 Orders, OptionChain, and Builders

`lib/tdameritrade/orders.ex`, `orders/{order,order_leg,strategies}.ex`, `option_chain.ex`

Added to close the developer-experience gap with the Python reference (see PYTHON_API_GAPS.md).

- Low-level fluent builders: `Order.new() |> Order.order_type("LIMIT") |> ... |> Order.add_leg(...)`
- High-level strategy constructors in `Strategies`: `market/1`, `limit/2`, `bracket/3`, `oco/2`, `iron_condor/4`, `covered_call/2`, `cash_secured_put/1`, verticals, butterflies, straddles, calendars, diagonals, synthetics, trailing stops, etc.
- All ultimately produce plain maps compatible with `PlaceOrder.place_order/3`, `CreateSavedOrder`, etc.
- `OptionChain` provides a similar ergonomic builder for the complex option-chain request parameters.

The builders encapsulate complexity while emitting the canonical TD wire format; callers never need to construct the deeply nested order JSON by hand.

### 3.7 Legacy Auth & Compatibility Layer

`lib/tdameritrade/auth.ex`

An `Agent`-backed store that holds per-"user" credential entries (access token, etc.). `put_token(user, token)` is the demo helper that bootstraps legacy paths.

Every modern public function accepts either a `%Client{}` or a binary user key. The legacy `use TDAmeritrade` macros (injected from every `Rest.*` and many `Stream.*` modules) hard-code `user = "default"`, fetch the token via `Auth.client(user)`, synthesize a Client, and delegate.

The old browser-login helpers in Auth now raise a clear error directing users to the modern token-injection path.

---

## 4. Key Design Decisions

| Decision | Choice | Rationale & Trade-offs | Evidence |
|----------|--------|------------------------|----------|
| **Hermetic verification** | All tests and demo run with zero network / live credentials via Bypass + Offline streamer + explicit `base_url` in Client | `mix test` is the suite; `mix test.ci` (format + warnings-as-errors + suite) is what CI runs | `td_bypass.ex`, `client.ex`, `connection.ex`, README "Running the Tests" section |
| **Client struct + explicit token** | Primary model is `Client.new(access_token: ...)`; legacy Agent auth is secondary | Clean separation of concerns; enables test isolation; modern OAuth usage is obvious | `client.ex` moduledoc, `rest.ex:24-33` `normalize/1` |
| **One module per REST endpoint** | 35 small files under `rest/` instead of a single monolithic client or code generation | Eliminates duplication of normalize/error logic via tiny shared `Rest`; each endpoint owns its docs, URL logic, and special cases; easy to add/test in isolation | `rest.ex:10-18` quote, uniform pattern across all 35 modules |
| **Plain maps for wire data** | Responses are `Poison.decode` maps; builders emit plain maps | API responses vary; strict structs would be brittle; maps are the natural Elixir representation for JSON | `error.ex:82-83`, `orders.ex` moduledoc |
| **Dual Real / Offline streamers with shared protocol logic** | Real uses WebSockex; Offline uses `push_frame`; both call the same `Parsers.parse_message` and `Commands` builders | Hermetic tests + demos possible while guaranteeing identical delivered messages and login behavior for production | `real.ex` and `offline.ex` moduledocs, `parsers.ex`, `commands.ex` |
| **Deprecation + macro injection** | Old flat API kept working via `use TDAmeritrade` + `@deprecated` + delegation | No breaking changes for existing callers; modern code sees clean namespaced modules | Every `Rest.*` `__using__` block, `tdameritrade.ex:37-73`, `stream.ex` |
| **Coverage is optional, not a gate** | `mix test --cover` ignores `Types.*`, thin legacy Stream facades, and `Real.SocketHandler`; CI does not fail on a percentage | Thin REST modules and Real streaming make a high Mix threshold unrealistic; the hermetic suite is the proof | `mix.exs` `test_coverage`, `.github/workflows/ci.yml` |
| **No code generation** | All 35 REST modules and streaming parsers hand-written | Simple, auditable, no extra build tooling; schemas/ and vendored Python are reference only | Absence of Mix generators, OpenAPI tasks, or template usage in lib/ |
| **Modern token injection primary** | `Auth.put_token/2` + Client for demos; old browser OAuth flow stubbed with error | Matches current best practice; removes dependency on deprecated flows | `auth.ex:74-82`, `PYTHON_API_GAPS.md` |
| **Orders builders added for parity** | Full `Orders.Strategies` + `OptionChain` fluent API producing wire maps | Closed the "Major Gap in Developer Experience" identified in the gap analysis | `PYTHON_API_GAPS.md`, `tdameritrade.ex:75-100`, `orders.ex` |

Additional notes:
- Query-string building is still duplicated across several REST modules (minor inconsistency, not yet extracted).
- `UNSUBS` command builder exists but is not currently emitted by Real/Offline (local state only); this is a known protocol incompleteness vs. full spec.

---

## 5. Data Flows & Examples

**REST call (modern path)**  
`GetQuote.get_quote(client, "AAPL")` → `Rest.get/2` (normalize) → `Connection.get` (HTTPoison with Bearer) → `Error.from_connection_result` → `{:ok, %{"AAPL" => ...}}` or `{:error, %Error{status: 404, ...}}`

**Streaming (hermetic demo)**  
`Offline.start_link()` → `subscribe("LEVELONE_EQUITY", "AAPL", "0,1,2,3", self())` → later `push_frame(sample_json)` → decode → `Parsers.parse_message` → deliver `{:tda_stream, "LEVELONE_EQUITY", [%{symbol: "AAPL", bid_price: ..., ...}]}` (or login event)

**Order construction**  
`Orders.Strategies.limit(leg, 175.0)` → internal `Order` / `OrderLeg` structs → `to_map/1` → plain map passed to `PlaceOrder.place_order(client, account_id, order_map)`

---

## 6. Testing & Verification Strategy

- **Contract tests** (`test/tdameritrade_*_test.exs`): Every REST call is exercised against an in-process Bypass server serving exact JSON fixtures from `test/fixtures/td_responses/`. `TdBypass.expect_json/5` + `client_for_bypass/1` make setup trivial.
- **Streaming tests**: Unit tests for Parsers/Commands, Offline tests using `push_frame` with canned frames (including LOGIN success/denied), limited Real tests for credential/command construction.
- **Core & builder tests**: Direct verification of Client, Error, Orders strategies, etc.
- **CI policy**: `mix test.ci` (the GitHub Actions command) runs format check, warnings-as-errors compile, and the hermetic suite. Plain `mix test` is the fast local suite. Coverage is optional (`mix test --cover`) and not gated.
- **QuietFormatter**: Custom GenServer formatter produces clean, CI-friendly output while still showing detailed diffs on failure.

The project is deliberately structured so that a maintainer or reviewer can run `mix test.ci` and verify that the historical API surface has been faithfully re-implemented.

---

## 7. Relationship to the Python Reference Client

See [PYTHON_API_GAPS.md](PYTHON_API_GAPS.md) for the detailed matrix.

- REST: near-complete parity (all ~35 endpoints); minor naming differences (`replace` vs `modify`, split watchlist/market-hours helpers).
- Builders: Order/OptionChain parity achieved with the addition of `TDAmeritrade.Orders.Strategies` and `OptionChain`.
- Streaming protocol: fully implemented (LOGIN, SUBS, numeric-field parsing, all message types). Developer ergonomics (high-level subscribe methods) remain the primary gap.
- Intentional omissions: legacy browser OAuth login flow, full set of Python convenience wrappers (generic subscribe is functionally complete).

The vendored Python source under `doc/td-ameritrade-python-api-0.3.5/` and the `schemas/` directory serve as reference material only; they are not used at runtime.

---

## 8. Project Layout & Tooling

- `lib/tdameritrade/` — all runtime code (`rest/`, `stream/`, `types/`, `orders/`, core modules).
- `test/fixtures/td_responses/` — 23 canonical JSON responses.
- `test/support/` — `TdBypass` and `QuietFormatter`.
- `schemas/` and `doc/` — historical reference artifacts from the Python client and TD API specifications.
- `mix.exs` — Elixir `~> 1.15`, `test.ci` alias (what CI runs), optional coverage ignores.
- No custom Mix tasks or code generators.

---

## 9. Maintenance, Extension & Limitations

**Adding a new REST endpoint**  
1. Create `lib/tdameritrade/rest/new_endpoint.ex` following the exact pattern (moduledoc, spec, primary function delegating to `TDAmeritrade.Rest.*`, `__using__` with deprecation).
2. Add a fixture under `test/fixtures/td_responses/`.
3. Write a contract test using `TdBypass`.
4. Wire the `use` statement into the top-level `TDAmeritrade` module if legacy support is required.

**Extending streaming**  
- Add or correct field ID mappings in `Parsers`.
- Add request builders in `Commands` if new ADMIN/SUBS variants appear.
- Exercise via `push_frame` in Offline tests (no network required).
- Update `Subscriptions` for any new high-level wrapper.

**Current limitations / gaps** (see also PYTHON_API_GAPS.md)
- High-level streaming subscribe methods are only partially implemented (generic `subscribe(service, keys, fields)` + Parsers cover the wire protocol).
- `UNSUBS` frames are not currently sent (local unsubscription only).
- No automatic reconnection or heartbeat handling beyond WebSockex defaults.
- Real streaming is difficult to test hermetically; credential and command logic is covered, but full end-to-end WS requires external recording.

**Deprecation policy**  
Legacy functions carry `@deprecated` and `IO.warn` messages pointing to the modern modules. The old surface can be removed in a future major version once callers have migrated.

The structure (small per-endpoint modules, shared helpers, dual hermetic streaming, explicit coverage carve-outs) is intentionally chosen to keep maintenance cost low for an archival reference library that may receive only occasional updates years after the live service has disappeared.

---

## 10. Glossary & References

- **Hermetic**: Tests that require no external network or live credentials (Bypass + Offline streamer).
- **Principals**: User principal data returned by `GetUserPrincipals`; contains streamer connection info and credentials used for the WS LOGIN handshake.
- **Numeric field IDs**: Compact integer strings (e.g. `"0"`, `"1"`) used by the TD streaming protocol to identify fields; mapped to atoms in `Parsers`.
- **Bypass**: In-process mock HTTP server used for contract tests.

Key files for further reading:
- `lib/tdameritrade/rest.ex:10-18` — rationale for the shared Rest helper
- `mix.exs` (`test_coverage`) — coverage philosophy and exclusions
- `lib/tdameritrade/stream/real.ex` and `offline.ex` — streaming architecture and unified contract
- `PYTHON_API_GAPS.md` — detailed porting status vs. Python reference
- `test/support/td_bypass.ex` — hermetic test foundation

---

*This document reflects the state of the library at version 0.2.0. It was produced by thorough static exploration of the source, test suite, and supporting documentation. Future changes should update the relevant sections and the version note above.*
