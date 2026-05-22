
defmodule TDAmeritrade.Types.Status do
  @typedoc """
  A string that is one of: "UNCHANGED", "CREATED", "UPDATED", "DELETED"
  """
  @type t :: binary() | String.t()

  @doc """
  iex> TDAmeritrade.Types.Status.is_valid?(%{})
  false
  iex> TDAmeritrade.Types.Status.is_valid?("xxx")
  false
  iex> TDAmeritrade.Types.Status.is_valid?(:unchanged)
  true
  iex> TDAmeritrade.Types.Status.is_valid?("UNCHANGED")
  true
  iex> TDAmeritrade.Types.Status.is_valid?(:created)
  true
  iex> TDAmeritrade.Types.Status.is_valid?("CREATED")
  true
  iex> TDAmeritrade.Types.Status.is_valid?(:updated)
  true
  iex> TDAmeritrade.Types.Status.is_valid?("UPDATED")
  true
  iex> TDAmeritrade.Types.Status.is_valid?(:deleted)
  true
  iex> TDAmeritrade.Types.Status.is_valid?("DELETED")
  true
  """

  @spec is_valid?(t) :: boolean()
  def is_valid?(status) when is_atom(status) do
    is_valid?(Atom.to_string(status))
  end

  def is_valid?(status) when is_binary(status) do
    status = String.upcase(status)

    status == "UNCHANGED" ||
      status == "CREATED" ||
      status == "UPDATED" ||
      status == "DELETED"
  end

  def is_valid?(_status), do: false
end
