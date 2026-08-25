# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Stream.Streamer_server do
  @moduledoc """
  Legacy "Streamer Server" module.

  Historical reference only.
  The real streaming connection is now managed by TDAmeritrade.Stream.Real.
  """

  use TDAmeritrade.Stream.Legacy, fun: :streamer_server
end
