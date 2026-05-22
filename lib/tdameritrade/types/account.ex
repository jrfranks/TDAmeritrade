
defmodule TDAmeritrade.Types.Account do
  @moduledoc """

    surrogateIds", [{"additionalProperties", [{"type", "string"}]}, {"type", "object"}] }
  %{ "Account" => TDAmeritrade.Types.SecuritiesAccount.t }
  """

  # (SecuritiesAccount require no longer needed)

  @typedoc """
  Account information structures
  """

  @type account_type :: String.t()
  @type surrogateID :: binary() | String.t()

  @type account :: %{
          type: account_type,
          accountId: String.t(),
          accountCdDomainId: String.t(),
          acl: String.t(),
          authorizations: TDAmeritrade.Types.Authorization.t(),
          company: String.t(),
          description: String.t(),
          displayName: String.t(),
          preferences: TDAmeritrade.Types.Preferences.t(),
          segment: String.t(),
          surrogateIds: [surrogateID, ...]
        }

  @type t :: map() | Account.t() | TDAmeritrade.Types.SecuritiesAccount.t()

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.Account.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.Account.is_valid?(%{:type => "CASH"})
    true
    iex> TDAmeritrade.Types.Account.is_valid?("x")
    false
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(account) when map_size(account) == 0, do: false
  def is_valid?(account) when is_map(account), do: true
  def is_valid?(_account), do: false
end
