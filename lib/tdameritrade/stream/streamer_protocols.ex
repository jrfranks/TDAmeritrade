# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Stream.StreamerProtocols do
  @moduledoc """
  Legacy "Streamer Protocols" documentation module.

  The WebSocket / HTTP / async protocol descriptions remain useful reference.
  Actual client implementation is TDAmeritrade.Stream.Real (WebSocket) and Offline.
  """

  use TDAmeritrade.Stream.Legacy, fun: :streamer_protocols
end
