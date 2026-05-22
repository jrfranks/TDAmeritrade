# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Stream.Streamer_server do
  @moduledoc """
  Legacy "Streamer Server" module.

  Historical reference only.
  The real streaming connection is now managed by TDAmeritrade.Stream.Real.
  """

  use TDAmeritrade.Stream.Legacy, fun: :streamer_server
end
