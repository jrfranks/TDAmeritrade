# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Stream.Chart do
  @moduledoc """
  Legacy CHART streaming module. Documentation preserved for reference.
  Real implementation: TDAmeritrade.Stream.Real + Parsers (CHART_EQUITY / CHART_FUTURES).
  """

  use TDAmeritrade.Stream.Legacy, fun: :chart
end
