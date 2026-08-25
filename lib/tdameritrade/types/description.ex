# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.Description do
  @typedoc """
  A description string
  """
  @type t :: binary() | String.t()

  @spec is_valid?(t) :: boolean()
  def is_valid?(desc) when is_binary(desc), do: true
  def is_valid?(_desc), do: false
end
