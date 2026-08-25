# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Rest.GetAccounts do
  @moduledoc """
  Retrieve the list of accounts for the authenticated user.

  Returns basic account information.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_accounts(Client.t() | binary(), keyword()) :: {:ok, list(map())} | {:error, Error.t()}

  def get_accounts(client_or_user, opts \\ []) do
    query =
      opts
      |> Enum.map(fn {k, v} -> "#{k}=#{URI.encode_www_form(to_string(v))}" end)
      |> Enum.join("&")

    url = "/v1/accounts" <> if query == "", do: "", else: "?" <> query
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_accounts do
    {:error, Error.new_client_error(:missing_client)}
  end

  defmacro __using__(_) do
    quote do
      def get_accounts(opts \\ []) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.GetAccounts.get_accounts(client, opts)
      end
    end
  end
end
