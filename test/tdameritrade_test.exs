# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritradeTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  @moduledoc """
  High-level smoke / legacy surface tests.

  The bulk of the contract testing lives in tdameritrade_contract_test.exs
  (the file formerly named tdameritrade_market_data_test.exs).

  The old flat API functions (TDAmeritrade.get_quote, TDAmeritrade.admin, etc.)
  are now thin wrappers / deprecation shims around the modern Rest.* and
  Stream.* modules. They are exercised indirectly by the contract tests.
  """

  # The legacy auth surface (login/logout) was heavily refactored.
  # The modern way is Client + put_token. We keep a minimal smoke test here
  # only to ensure the module still loads.
  test "basic module loads and Connection can start" do
    assert {:ok, _} = TDAmeritrade.Connection.start_link()
    assert TDAmeritrade.Connection.stop() == :ok
  end

  # Legacy flat streaming functions now emit IO.warn deprecation messages.
  # We do not assert on the exact text here to keep the test stable, but
  # calling them should not crash.
  test "legacy flat streaming functions still callable (emit deprecation)" do
    # Capture deprecation warnings so they don't appear in normal test output
    warnings =
      capture_io(:stderr, fn ->
        # These now go through the Legacy shim
        assert TDAmeritrade.admin() == :ok
        assert TDAmeritrade.level_one() == :ok
        assert TDAmeritrade.chart() == :ok
      end)

    assert warnings =~ "deprecated"
  end
end
