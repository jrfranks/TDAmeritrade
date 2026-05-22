ExUnit.start(
  # Extremely minimal output using our custom formatter.
  # Use `mix test --trace` during development if you need per-test details.
  colors: true,
  trace: false,
  seed: 0,
  timeout: 60_000,
  formatters: [TDAmeritrade.QuietFormatter]
)
