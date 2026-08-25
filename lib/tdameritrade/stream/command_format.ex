# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Stream.CommandFormat do
  @moduledoc """
  Legacy "Command Format" streaming documentation.

  Kept for historical reference. Modern code is in Commands + Real/Offline.
  """

  use TDAmeritrade.Stream.Legacy, fun: :command_format
end
