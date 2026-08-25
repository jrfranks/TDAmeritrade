# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Connection do
  @moduledoc """
  Low-level HTTP transport for the TD Ameritrade API.

  Accepts either a legacy binary "user" key (resolved via Auth) **or** a
  %TDAmeritrade.Client{} struct (preferred for the self-contained demo).

  When a Client with a `base_url` is supplied, all paths are resolved against
  that base (enables Bypass contract tests).
  """

  alias TDAmeritrade.Client

  @default_base "https://api.tdameritrade.com"

  @spec start_link() :: {:error, any} | {:ok, pid}
  def start_link() do
    TDAmeritrade.Auth.start_link()
  end

  @spec stop() :: :ok
  def stop() do
    TDAmeritrade.Auth.stop()
  end

  def login(user) do
    TDAmeritrade.Auth.login(user)
  end

  def logout(user) do
    TDAmeritrade.Auth.logout(user)
  end

  # Public API — first argument can be Client or legacy binary user
  def get(target, url, headers \\ [], opts \\ []),
    do: request(:get, target, url, "", headers, opts)

  def get!(target, url, headers \\ [], opts \\ []),
    do: request!(:get, target, url, "", headers, opts)

  def post(target, url, body \\ "", headers \\ [], opts \\ []),
    do: request(:post, target, url, body, headers, opts)

  def post!(target, url, body \\ "", headers \\ [], opts \\ []),
    do: request!(:post, target, url, body, headers, opts)

  def put(target, url, body \\ "", headers \\ [], opts \\ []),
    do: request(:put, target, url, body, headers, opts)

  def put!(target, url, body \\ "", headers \\ [], opts \\ []),
    do: request!(:put, target, url, body, headers, opts)

  def patch(target, url, body \\ "", headers \\ [], opts \\ []),
    do: request(:patch, target, url, body, headers, opts)

  def patch!(target, url, body \\ "", headers \\ [], opts \\ []),
    do: request!(:patch, target, url, body, headers, opts)

  def delete(target, url, body \\ "", headers \\ [], opts \\ []),
    do: request(:delete, target, url, body, headers, opts)

  def delete!(target, url, body \\ "", headers \\ [], opts \\ []),
    do: request!(:delete, target, url, body, headers, opts)

  def subscribe(_user, _topic, _callback), do: :ok
  def unsubscribe(_user, _topic), do: :ok

  # --- Core request logic ---

  defp request(verb, target, url, body, headers, opts) do
    {full_url, final_headers} = prepare(target, url, headers)

    case target do
      %Client{} ->
        # Demo / test path — direct HTTPoison so Bypass works
        HTTPoison.request(verb, full_url, body, final_headers, opts)

      _binary_user ->
        # Legacy path — keep using the existing OAuth2 client machinery
        tdclient = TDAmeritrade.Auth.client(target)
        # OAuth2.Client.* methods take the path (we already made it absolute for consistency,
        # but OAuth2 will usually accept it). If problems appear, we can strip the host here.
        apply(OAuth2.Client, verb, [tdclient, full_url, body, final_headers, opts])
    end
  end

  defp request!(verb, target, url, body, headers, opts) do
    case request(verb, target, url, body, headers, opts) do
      {:ok, resp} -> resp
      {:error, err} -> raise err
    end
  end

  # Returns {full_url, headers_with_auth}
  defp prepare(target, url, extra_headers) do
    base =
      case target do
        %Client{base_url: b} when is_binary(b) -> b
        _ -> @default_base
      end

    path = if String.starts_with?(url, "/"), do: url, else: "/" <> url
    full_url = String.trim_trailing(base, "/") <> path

    auth_header =
      case target do
        %Client{access_token: t} when is_binary(t) and t != "" ->
          {"Authorization", "Bearer #{t}"}

        _ ->
          nil
      end

    headers = [auth_header | extra_headers] |> Enum.reject(&is_nil/1)
    {full_url, headers}
  end

  # --- Macro surface (unchanged for backward compatibility) ---

  defmacro __using__(_) do
    quote do
      def login(user), do: safe_call(:login, [user])
      def logout(user), do: safe_call(:logout, [user])

      def get(user, url, headers \\ [], opts \\ []),
        do: safe_call(:get, [user, url, headers, opts])

      def get!(user, url, headers \\ [], opts \\ []),
        do: TDAmeritrade.Connection.get!(user, url, headers, opts)

      def post(user, url, body \\ "", headers \\ [], opts \\ []),
        do: safe_call(:post, [user, url, body, headers, opts])

      def post!(user, url, body \\ "", headers \\ [], opts \\ []),
        do: TDAmeritrade.Connection.post!(user, url, body, headers, opts)

      def put(user, url, body \\ "", headers \\ [], opts \\ []),
        do: safe_call(:put, [user, url, body, headers, opts])

      def put!(user, url, body \\ "", headers \\ [], opts \\ []),
        do: TDAmeritrade.Connection.put!(user, url, body, headers, opts)

      def patch(user, url, body \\ "", headers \\ [], opts \\ []),
        do: safe_call(:patch, [user, url, body, headers, opts])

      def patch!(user, url, body \\ "", headers \\ [], opts \\ []),
        do: TDAmeritrade.Connection.patch!(user, url, body, headers, opts)

      def delete(user, url, body \\ "", headers \\ [], opts \\ []),
        do: safe_call(:delete, [user, url, body, headers, opts])

      def delete!(user, url, body \\ "", headers \\ [], opts \\ []),
        do: TDAmeritrade.Connection.delete!(user, url, body, headers, opts)

      def subscribe(user, topic, callback), do: safe_call(:subscribe, [user, topic, callback])
      def unsubscribe(user, topic), do: safe_call(:unsubscribe, [user, topic])

      defp safe_call(fun, args) do
        try do
          apply(TDAmeritrade.Connection, fun, args)
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
