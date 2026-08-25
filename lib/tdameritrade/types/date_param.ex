# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Types.DateParam do
  @moduledoc """
  TDAmeritrade Date Parameter
  """
  @typedoc """
  A Date string or Unix timestamp
  %{
    "DateParam"=> [
      { "date", [ {"type","string"} ] },
      { "shortFormat", [ {"default",false}, {"type","boolean"} ] }
    ]
  }
  """

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.DateParam.is_valid?(%{})
    false

    iex> TDAmeritrade.Types.DateParam.is_valid?(1665446325)
    true

    iex> TDAmeritrade.Types.DateParam.is_valid?("Mon 10 Oct 2022 11:56:34 PM UTC")
    true

    iex> TDAmeritrade.Types.DateParam.is_valid?("Mon, 10 Oct 2022 20:35:33 GMT")
    true

    iex> TDAmeritrade.Types.DateParam.is_valid?("2015-01-23T23:50:07,123+02:30")
    true
  """

  @type date :: binary() | String.t()
  @type t :: %{
          date: date,
          shortFormat: boolean
        }

  @spec is_valid?(DateParam.t()) :: boolean()
  def is_valid?(date) when is_integer(date), do: true

  def is_valid?(date) when is_binary(date) do
    regex =
      ~r"(Mon|Tue|Wed|Thu|Fri|Sat|Sun),* [0-9]+ (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]+ [0-9]+:[0-9]+:[0-9]+ [A-Z]+"

    r = Regex.run(regex, date)

    case r do
      [_, _, _] ->
        true

      _ ->
        case DateTime.from_iso8601(date) do
          {:ok, _, _} -> true
          _ -> false
        end
    end
  end

  def is_valid?(_date), do: false
end
