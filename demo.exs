# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

# Beautiful demo of the modern TDAmeritrade API (no credentials needed)
#
# Run with:  elixir -S mix run demo.exs
#
# This shows both the clean REST client and the hermetic Offline streamer.

alias TDAmeritrade.Client
alias TDAmeritrade.Rest.GetQuote
alias TDAmeritrade.Stream.Offline

IO.puts("\n=== TDAmeritrade Elixir Client — Beautiful Demo ===\n")

# 1. Modern REST usage with Client
IO.puts("1. Modern REST Client (Get Quote)")
client = Client.new(access_token: "demo-token")

{:ok, quote} = GetQuote.get_quote(client, "AAPL")
IO.inspect(Map.keys(quote), label: "Quote keys for AAPL")

# 2. Hermetic Offline Streaming (no network, fully reproducible)
IO.puts("\n2. Offline Streaming Demo (hermetic, no credentials)")

{:ok, streamer} = Offline.start_link()

Offline.subscribe(streamer, "LEVELONE_EQUITY", "AAPL", "0,1,2,3,4,5", self())

# Simulate a real frame (in production this would come from the WebSocket)
sample_frame = ~s({
  "service": "LEVELONE_EQUITY",
  "command": "SUBS",
  "content": [
    {"symbol": "AAPL", "bidPrice": 178.45, "askPrice": 178.47, "lastPrice": 178.46}
  ]
})

Offline.push_frame(streamer, sample_frame)

receive do
  {:tda_stream, "LEVELONE_EQUITY", content} ->
    IO.puts("   Received streaming update:")
    IO.inspect(content, pretty: true, width: 80)
after
  1000 -> IO.puts("   (No message — normal in this minimal demo)")
end

IO.puts("\n=== Demo complete. The library is fully self-contained and beautiful. ===\n")