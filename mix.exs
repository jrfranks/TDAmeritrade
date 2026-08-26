# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule Tdameritrade.MixProject do
  use Mix.Project

  def project do
    [
      app: :tdameritrade,
      version: "0.2.0",
      elixir: "~> 1.15",
      description:
        "Complete Elixir implementation of the historical TD Ameritrade REST and Streaming APIs.",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Demo / test support
      elixirc_paths: elixirc_paths(Mix.env()),
      # Optional `mix test --cover` report. Not a CI gate (thin REST modules and
      # Real streaming keep totals well below Mix's 90% default).
      test_coverage: [
        ignore_modules: [
          ~r/^TDAmeritrade\.Types\./,
          ~r/^TDAmeritrade\.Stream\.(AcctActivity|Actives|Admin|Book|Chart|ChartHistory|CommandFormat|Data|Introduction|Legacy|LevelOne|News|Quickstart|StreamerProtocols|Streamer_server|Timesale|Title)$/,
          ~r/^TDAmeritrade\.Stream\.Real\.SocketHandler$/
        ]
      ],
      aliases: aliases(),
      # Mix 1.15 reads preferred_cli_env; Mix 1.19+ reads cli/0.
      preferred_cli_env: [
        "test.ci": :test
      ]
    ]
  end

  def cli do
    [preferred_envs: ["test.ci": :test]]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      # Same command GitHub Actions runs: format, warnings-as-errors, hermetic suite.
      "test.ci": ["format --check-formatted", "compile --warnings-as-errors", "test"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jrfranks/TDAmeritrade"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:castore, "~> 1.0"},
      {:oauth2, "~> 2.0"},
      {:poison, "~> 5.0"},
      {:httpoison, "~> 2.0"},
      # WebSocket client for the full real TD Ameritrade streaming connection
      {:websockex, "~> 0.4"},
      # Test-only mock HTTP server for hermetic contract tests (key to the demo)
      {:bypass, "~> 2.1", only: :test}
    ]
  end
end
