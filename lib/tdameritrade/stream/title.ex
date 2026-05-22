# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Stream.Title do
  @moduledoc """
  Legacy "Title" streaming module.

  Historical documentation preserved for reference.
  Real streaming implementation now lives in TDAmeritrade.Stream.Real / Offline.
  """

  use TDAmeritrade.Stream.Legacy, fun: :title
end
