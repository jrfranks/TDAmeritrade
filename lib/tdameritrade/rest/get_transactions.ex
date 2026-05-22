# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.GetTransactions do
  @moduledoc """
  Retrieve transactions for an account (trades, dividends, etc.).
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_transactions(Client.t() | binary(), String.t(), keyword()) ::
          {:ok, list(map())} | {:error, Error.t()}

  # Support default opts
  def get_transactions(client_or_user, account_id, opts \\ [])

  def get_transactions(_client_or_user, nil, _opts) do
    {:error, Error.new_client_error(:invalid_account_id, "account_id cannot be nil")}
  end

  def get_transactions(client_or_user, account_id, opts) when is_binary(account_id) do
    client = TDAmeritrade.Rest.normalize(client_or_user)

    query =
      opts
      |> Enum.map(fn {k, v} -> "#{k}=#{URI.encode_www_form(to_string(v))}" end)
      |> Enum.join("&")

    url = "/v1/accounts/#{account_id}/transactions" <> if query == "", do: "", else: "?" <> query

    TDAmeritrade.Connection.get(client, url)
    |> Error.from_connection_result()
  end

  def get_transactions do
    {:error, Error.new_client_error(:missing_account_id_and_client)}
  end

  defmacro __using__(_) do
    quote do
      # Declare the default argument once for multiple clauses
      def get_transactions(account_id, opts \\ [])

      def get_transactions(nil, _opts) do
        {:error, Error.new_client_error(:invalid_account_id, "account_id cannot be nil")}
      end

      def get_transactions(account_id, opts) when is_binary(account_id) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.GetTransactions.get_transactions(client, account_id, opts)
      end

      def get_transactions do
        try do
          TDAmeritrade.Rest.GetTransactions.get_transactions()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
