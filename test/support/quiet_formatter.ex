# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.QuietFormatter do
  @moduledoc """
  Clean per-test ExUnit formatter.

  - Prints every test result (what is being tested + pass/fail)
  - On failure, prints ACTUAL and EXPECTED clearly
  - No noisy "Running ExUnit" header
  - No deprecation warnings (handled globally in test_helper)
  """

  use GenServer

  def init(_opts) do
    {:ok, %{passed: 0, failed: 0}}
  end

  # Suppress the initial "Running ExUnit with seed..." line
  def handle_cast({:suite_started, _opts}, state) do
    {:noreply, state}
  end

  def handle_cast({:test_started, _test}, state) do
    {:noreply, state}
  end

  def handle_cast({:test_finished, test}, state) do
    name = format_test_name(test)

    case test.state do
      nil ->
        IO.puts("✓ #{name}")
        {:noreply, %{state | passed: state.passed + 1}}

      {:failed, _failed} ->
        IO.puts("✗ #{name}")
        print_failure_details(test)
        {:noreply, %{state | failed: state.failed + 1}}

      {:skipped, _} ->
        IO.puts("↷ #{name} (skipped)")
        {:noreply, state}

      {:excluded, _} ->
        {:noreply, state}
    end
  end

  def handle_cast({:suite_finished, _run_info}, state) do
    total = state.passed + state.failed

    if state.failed == 0 do
      IO.puts("\n✅ All #{total} tests passed successfully.")
    else
      IO.puts("\n❌ #{state.failed} of #{total} tests failed.")
    end

    {:noreply, state}
  end

  def handle_cast(_event, state) do
    {:noreply, state}
  end

  # --- Helpers ---

  defp format_test_name(test) do
    # Try to make a nice name from tags
    describe = test.tags[:describe]
    test_title = test.tags[:test] || test.name

    if describe do
      "#{describe} — #{test_title}"
    else
      test_title
    end
  end

  defp print_failure_details(test) do
    case test.state do
      {:failed, [first_failure | _]} ->
        print_assertion_or_reason(first_failure)

      _ ->
        IO.puts("    (unexpected failure state)")
    end
  end

  defp print_assertion_or_reason({:error, %ExUnit.AssertionError{} = error, _stacktrace}) do
    if error.expr do
      IO.puts("    Expression: #{inspect(error.expr)}")
    end

    if Map.has_key?(error, :left) and error.left != nil do
      IO.puts("    ACTUAL:   #{inspect(error.left)}")
    end

    if Map.has_key?(error, :right) and error.right != nil do
      IO.puts("    EXPECTED: #{inspect(error.right)}")
    end

    if error.message do
      IO.puts("    Message:  #{error.message}")
    end
  end

  defp print_assertion_or_reason({_kind, reason, _stacktrace}) do
    # Always force ACTUAL / EXPECTED format for consistency, even for non-assertion errors
    case reason do
      %FunctionClauseError{args: args} ->
        bad_arg = if is_list(args), do: List.first(args), else: args
        IO.puts("    ACTUAL:   #{inspect(bad_arg)}")
        IO.puts("    EXPECTED: valid input (not nil)")

      %ArgumentError{message: msg} ->
        IO.puts("    ACTUAL:   #{inspect(reason)}")
        IO.puts("    EXPECTED: valid data structure (got error: #{msg})")

      other ->
        IO.puts("    ACTUAL:   #{inspect(other)}")
        IO.puts("    EXPECTED: successful execution without error")
    end
  end
end
