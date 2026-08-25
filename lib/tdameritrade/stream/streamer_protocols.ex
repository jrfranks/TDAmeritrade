# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Stream.StreamerProtocols do
  @moduledoc """
  Legacy "Streamer Protocols" documentation module.

  The WebSocket / HTTP / async protocol descriptions remain useful reference.
  Actual client implementation is TDAmeritrade.Stream.Real (WebSocket) and Offline.
  """

  use TDAmeritrade.Stream.Legacy, fun: :streamer_protocols
end
