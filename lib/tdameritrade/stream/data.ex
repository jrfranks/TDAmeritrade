# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Stream.Data do
  @moduledoc """
  Legacy "Data" streaming module.

  Historical protocol documentation preserved.
  Real implementation: TDAmeritrade.Stream.Real + Parsers.
  """

  use TDAmeritrade.Stream.Legacy, fun: :data
end
