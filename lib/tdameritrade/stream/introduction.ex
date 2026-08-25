# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Stream.Introduction do
  @moduledoc """
  Legacy "Introduction" streaming documentation module.

  The original content is kept as historical reference.
  Use TDAmeritrade.Stream.Real or Offline for actual streaming.
  """

  use TDAmeritrade.Stream.Legacy, fun: :introduction
end
