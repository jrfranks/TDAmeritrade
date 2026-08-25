# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Stream.ChartHistory do
  @moduledoc """
  Legacy "Chart History" streaming module.

  Historical docs kept. Real CHART_HISTORY support lives in the modern streamer + parsers.
  """

  use TDAmeritrade.Stream.Legacy, fun: :chart_history
end
