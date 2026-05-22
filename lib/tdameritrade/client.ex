# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (updated for demo)
# -
defmodule TDAmeritrade.Client do
  @moduledoc """
  Lightweight, immutable client session for the TD Ameritrade (historical) API.

  ## Recommended Usage (Modern API)

      client = TDAmeritrade.Client.new(access_token: "YOUR_TOKEN")
      {:ok, quote} = TDAmeritrade.Rest.GetQuote.get_quote(client, "AAPL")

  ## Demo / Test Usage

  Because the real TD Ameritrade services have been retired, the primary
  constructor accepts an explicit `access_token` (and optional `base_url` for
  Bypass-based contract tests). This design makes the entire test suite
  hermetic and reproducible with zero network access.

  The legacy multi-user Agent-based auth surface (`TDAmeritrade.Auth`) is
  still supported for backward compatibility with the original high-level API.
  """

  @type t :: %__MODULE__{
          access_token: String.t() | nil,
          user: String.t() | nil,
          account_id: String.t() | nil,
          base_url: String.t() | nil
        }

  defstruct access_token: nil,
            user: nil,
            account_id: nil,
            base_url: nil

  @doc """
  Create a new client.

  In normal usage you would obtain a real OAuth access token. For this
  self-contained historical demo we simply pass one in (or use Bypass
  + `base_url` during tests).

  ## Examples

      client = TDAmeritrade.Client.new(access_token: "demo-token-123")
      client = TDAmeritrade.Client.new(access_token: "token", base_url: "http://localhost:12345")
  """
  def new(opts \\ []) do
    struct!(__MODULE__, opts)
  end

  @doc """
  Returns true if the client has a usable access token.
  """
  def has_token?(%__MODULE__{access_token: token}) when is_binary(token), do: token != ""
  def has_token?(_), do: false

  @doc """
  Convenience accessor returning the Bearer header value.
  """
  def auth_header(%__MODULE__{access_token: token}) when is_binary(token) do
    {"Authorization", "Bearer #{token}"}
  end

  def auth_header(_), do: {"Authorization", "Bearer "}
end
