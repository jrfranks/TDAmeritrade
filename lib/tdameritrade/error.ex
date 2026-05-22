# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Error do
  @moduledoc """
  Standardized error struct returned by all TDAmeritrade REST calls.

  This replaces the previous inconsistent `{:error, term()}` returns
  (raw atoms, HTTPoison errors, maps, etc.).
  """

  @type t :: %__MODULE__{
          status: integer() | atom(),
          body: term(),
          reason: atom() | nil,
          message: String.t() | nil
        }

  defstruct [:status, :body, :reason, :message]

  @doc """
  Create an error from an HTTP status + body (the most common case).
  """
  def new(status, body) when is_integer(status) or is_atom(status) do
    %__MODULE__{
      status: status,
      body: body,
      reason: :http_error,
      message: "HTTP request failed with status #{status}"
    }
  end

  @doc """
  Create a transport-level error (e.g. connection refused, timeout).
  """
  def new_transport(reason) do
    %__MODULE__{
      status: :transport,
      body: nil,
      reason: reason,
      message: "Transport error: #{inspect(reason)}"
    }
  end

  @doc """
  Create an error for JSON decoding failures.
  """
  def new_json_error(original_error) do
    %__MODULE__{
      status: :json_decode,
      body: original_error,
      reason: :json_decode,
      message: "Failed to decode JSON response"
    }
  end

  @doc """
  Create a client-side validation / usage error (e.g. missing required argument).
  """
  def new_client_error(reason, details \\ nil) do
    %__MODULE__{
      status: :client_error,
      body: details,
      reason: reason,
      message: "Client error: #{reason}"
    }
  end

  @doc """
  Convenience constructor used by the REST layer.
  Accepts the raw result from Connection.get/put/etc. and returns
  either {:ok, decoded} or {:error, %TDAmeritrade.Error{}}.
  """
  def from_connection_result(result) do
    case result do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Poison.decode(body) do
          {:ok, data} -> {:ok, data}
          {:error, err} -> {:error, new_json_error(err)}
        end

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, new(status, body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, new_transport(reason)}

      other ->
        {:error, new_client_error(:unexpected_response, other)}
    end
  end
end
