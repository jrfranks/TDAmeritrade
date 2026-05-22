# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.GetTransaction do
  @moduledoc """
  Retrieve a single transaction by ID.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_transaction(Client.t() | binary(), String.t(), String.t()) ::
          {:ok, map()} | {:error, Error.t()}

  def get_transaction(client_or_user, account_id, transaction_id)
      when is_binary(account_id) and is_binary(transaction_id) do
    url = "/v1/accounts/#{account_id}/transactions/#{transaction_id}"
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_transaction do
    {:error, Error.new_client_error(:missing_account_and_transaction_id)}
  end

  defmacro __using__(_) do
    quote do
      def get_transaction(account_id, transaction_id)
          when is_binary(account_id) and is_binary(transaction_id) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.GetTransaction.get_transaction(client, account_id, transaction_id)
      end

      def get_transaction do
        try do
          TDAmeritrade.Rest.GetTransaction.get_transaction()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
