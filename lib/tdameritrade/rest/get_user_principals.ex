# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Rest.GetUserPrincipals do
  @moduledoc """
  Get user principal information, including streamer connection details (required for real streaming).
  """

  alias TDAmeritrade.Client
  alias TDAmeritrade.Error

  @spec get_user_principals(Client.t() | binary(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}

  def get_user_principals(client_or_user, opts \\ []) do
    query =
      opts
      |> Enum.map(fn {k, v} -> "#{k}=#{URI.encode_www_form(to_string(v))}" end)
      |> Enum.join("&")

    url = "/v1/userprincipals" <> if query == "", do: "", else: "?" <> query
    TDAmeritrade.Rest.get(client_or_user, url)
  end

  def get_user_principals do
    {:error, Error.new_client_error(:missing_client)}
  end

  defmacro __using__(_) do
    quote do
      def get_user_principals(opts \\ []) do
        user = "default"
        token = TDAmeritrade.Auth.client(user)
        client = TDAmeritrade.Client.new(access_token: token)
        TDAmeritrade.Rest.GetUserPrincipals.get_user_principals(client, opts)
      end
    end
  end
end
