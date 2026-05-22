# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Stream.Timesale do
  @moduledoc """
  Legacy TIMESALE streaming module.
  """

  use TDAmeritrade.Stream.Legacy, fun: :timesale
end
