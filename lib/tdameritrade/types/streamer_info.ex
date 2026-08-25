# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.StreamerInfo do
  @moduledoc """
  %{
    "StreamerInfo" => [
      {"properties",
       [
         {"accessLevel", [{"type", "string"}]},
         {"acl", [{"type", "string"}]},
         {"appId", [{"type", "string"}]},
         {"streamerBinaryUrl", [{"type", "string"}]},
         {"streamerSocketUrl", [{"type", "string"}]},
         {"token", [{"type", "string"}]},
         {"tokenTimestamp", [{"format", "date-time"}, {"type", "string"}]},
         {"userGroup", [{"type", "string"}]}
       ]},
      {"type", "object"}
    ]
  }
  """

  @typedoc """

  """
  @type t :: map()

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.StreamerInfo.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.StreamerInfo.is_valid?(x)
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(info) when map_size(info) == 0, do: true
  def is_valid?(info) when is_map(info), do: true
  def is_valid?(_info), do: false
end
