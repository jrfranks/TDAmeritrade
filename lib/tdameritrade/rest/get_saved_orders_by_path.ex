# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Rest.GetSavedOrdersByPath do
  @moduledoc """
  List saved orders for a specific account.
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_saved_orders_by_path(Client.t() | binary(), String.t(), keyword()) ::
          {:ok, list(map())} | {:error, Error.t()}

  def get_saved_orders_by_path(client_or_user, account_id, opts \\ [])
      when is_binary(account_id) do
    query =
      opts
      |> Enum.map(fn {k, v} -> "#{k}=#{URI.encode_www_form(to_string(v))}" end)
      |> Enum.join("&")

    url = "/v1/accounts/#{account_id}/savedorders" <> if query == "", do: "", else: "?" <> query
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_saved_orders_by_path do
    {:error, Error.new_client_error(:missing_account_id_and_client)}
  end

  defmacro __using__(_) do
    quote do
      def get_saved_orders_by_path(account_id, opts \\ []) when is_binary(account_id) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.GetSavedOrdersByPath.get_saved_orders_by_path(client, account_id, opts)
      end

      def get_saved_orders_by_path do
        try do
          TDAmeritrade.Rest.GetSavedOrdersByPath.get_saved_orders_by_path()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
