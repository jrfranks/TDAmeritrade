# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Stream.Subscriptions do
  @moduledoc """
  High-level streaming subscription helpers that mirror the Python
  `TDStreamerClient` API for improved developer experience.

  These are thin, convenient wrappers around the generic
  `TDAmeritrade.Stream.Real.subscribe/4` (and the same on `Offline`).

  They make the Elixir streaming API feel much closer to the reference
  Python implementation while preserving the full power of the generic
  subscribe method for any service.
  """

  alias TDAmeritrade.Stream.Real
  alias TDAmeritrade.Stream.Offline

  # --- Level One (Equity / Options / Futures / Forex) ---

  def level_one_quotes(streamer, symbols, fields) when is_binary(symbols) do
    Real.subscribe(streamer, "LEVELONE_EQUITY", symbols, fields)
  end

  def level_one_options(streamer, symbols, fields) when is_binary(symbols) do
    Real.subscribe(streamer, "LEVELONE_OPTION", symbols, fields)
  end

  def level_one_futures(streamer, symbols, fields) when is_binary(symbols) do
    Real.subscribe(streamer, "LEVELONE_FUTURES", symbols, fields)
  end

  def level_one_forex(streamer, symbols, fields) when is_binary(symbols) do
    Real.subscribe(streamer, "LEVELONE_FOREX", symbols, fields)
  end

  def level_one_futures_options(streamer, symbols, fields) when is_binary(symbols) do
    Real.subscribe(streamer, "LEVELONE_FUTURES_OPTIONS", symbols, fields)
  end

  # --- News & Timesale ---

  def news_headline(streamer, symbols, fields) when is_binary(symbols) do
    Real.subscribe(streamer, "NEWS_HEADLINE", symbols, fields)
  end

  def timesale(streamer, service, symbols, fields)
      when is_binary(service) and is_binary(symbols) do
    Real.subscribe(streamer, service, symbols, fields)
  end

  # --- Chart & Actives ---

  def chart(streamer, service, symbols, fields) when is_binary(service) and is_binary(symbols) do
    Real.subscribe(streamer, service, symbols, fields)
  end

  def actives(streamer, service, venue, duration)
      when is_binary(service) and is_binary(venue) and is_binary(duration) do
    # actives uses a special key format "venue!duration"
    key = "#{venue}!#{duration}"
    # standard active fields
    Real.subscribe(streamer, service, key, "0,1,2,3,4,5")
  end

  def account_activity(streamer, account_id) when is_binary(account_id) do
    Real.subscribe(streamer, "ACCT_ACTIVITY", account_id, "0,1,2,3")
  end

  def chart_history_futures(
        streamer,
        symbol,
        frequency,
        _start_time \\ nil,
        _end_time \\ nil,
        _period \\ nil
      ) do
    # Simplified; real usage builds a more complex request via Commands
    Real.subscribe(streamer, "CHART_HISTORY_FUTURES", symbol, "#{frequency}")
  end

  # --- Quality of Service ---

  def quality_of_service(streamer, qos_level) when is_integer(qos_level) do
    # This is an ADMIN command, not a data subscription.
    # Dispatch to the correct backend (Real or Offline) for API symmetry.
    target =
      cond do
        streamer == Offline or streamer == TDAmeritrade.Stream.Offline -> Offline
        true -> Real
      end

    target.quality_of_service(streamer, qos_level)
  end

  # --- Common Level Two (Book) helpers for the most frequently used ones ---

  def level_two_quotes(streamer, symbols, fields) when is_binary(symbols) do
    Real.subscribe(streamer, "LEVELTWO_EQUITY", symbols, fields)
  end

  def level_two_options(streamer, symbols, fields) when is_binary(symbols) do
    Real.subscribe(streamer, "LEVELTWO_OPTION", symbols, fields)
  end

  # --- Same API on Offline (for hermetic testing / demos) ---

  def level_one_quotes_offline(streamer, symbols, fields) when is_binary(symbols) do
    Offline.subscribe(streamer, "LEVELONE_EQUITY", symbols, fields)
  end

  def news_headline_offline(streamer, symbols, fields) when is_binary(symbols) do
    Offline.subscribe(streamer, "NEWS_HEADLINE", symbols, fields)
  end

  # ... (add more offline variants as needed; the pattern is identical)
end
