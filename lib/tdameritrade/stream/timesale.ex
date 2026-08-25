# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Stream.Timesale do
  @moduledoc """
  Legacy TIMESALE streaming module.
  """

  use TDAmeritrade.Stream.Legacy, fun: :timesale
end
