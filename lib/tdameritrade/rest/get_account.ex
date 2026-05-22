# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.GetAccount do
  @moduledoc """
  Get detailed information for a specific account (balances, positions, orders, etc.).
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_account(Client.t() | binary(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}

  def get_account(client_or_user, account_id, opts \\ []) when is_binary(account_id) do
    query =
      opts
      |> Enum.map(fn {k, v} -> "#{k}=#{URI.encode_www_form(to_string(v))}" end)
      |> Enum.join("&")

    url = "/v1/accounts/#{account_id}" <> if query == "", do: "", else: "?" <> query
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_account do
    {:error, Error.new_client_error(:missing_account_id_and_client)}
  end

  defmacro __using__(_) do
    quote do
      @deprecated "Use TDAmeritrade.Rest.GetAccount.get_account/3 (with a Client) instead"
      def get_account(account_id, opts \\ []) when is_binary(account_id) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.GetAccount.get_account(client, account_id, opts)
      end

      @deprecated "Use TDAmeritrade.Rest.GetAccount.get_account/3 instead"
      def get_account do
        try do
          TDAmeritrade.Rest.GetAccount.get_account()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
