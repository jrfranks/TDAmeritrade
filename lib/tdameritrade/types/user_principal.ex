# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.UserPrincipal do
  @moduledoc """
  %{
    "UserPrincipal" => [
      {"properties",
       [
         {"accessLevel", [{"type", "string"}]},
         {"accounts", [{"items", [{"$dict", "Account"}]}, {"type", "array"}]},
         {"authToken", [{"type", "string"}]},
         {"lastLoginTime", [{"format", "date-time"}, {"type", "string"}]},
         {"loginTime", [{"format", "date-time"}, {"type", "string"}]},
         {"primaryAccountId", [{"type", "string"}]},
         {"professionalStatus",
          [{"enum", ["PROFESSIONAL", "NON_PROFESSIONAL", "UNKNOWN_STATUS"]}, {"type", "string"}]},
         {"quotes", [{"$dict", "Quote"}]},
         {"stalePassword", [{"default", false}, {"type", "boolean"}]},
         {"streamerInfo", [{"$dict", "StreamerInfo"}]},
         {"streamerSubscriptionKeys", [{"$dict", "SubscriptionKey"}]},
         {"tokenExpirationTime", [{"format", "date-time"}, {"type", "string"}]},
         {"userCdDomainId", [{"type", "string"}]},
         {"userId", [{"type", "string"}]}
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
    iex> TDAmeritrade.Types.UserPrincipal.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.UserPrincipal.is_valid?(x)
    true
  """
  def is_valid?(user_principal) when map_size(user_principal) == 0, do: true
  def is_valid?(user_principal) when is_map(user_principal), do: true
  def is_valid?(_user_principal), do: false
end
