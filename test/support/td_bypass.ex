# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
# -
#
defmodule TDAmeritrade.TestSupport.TdBypass do
  @moduledoc """
  Helpers for contract-testing the TDAmeritrade client against an in-process
  mock HTTP server (Bypass). This is the foundation of the self-contained demo.
  """

  alias TDAmeritrade.Client

  @doc """
  Starts a Bypass server and returns its pid.
  """
  def start do
    Bypass.open()
  end

  @doc """
  Registers an expectation on the Bypass server.

  - `bypass`  : the pid returned by start/0
  - `method`  : "GET", "POST", "PUT", "DELETE"
  - `path`    : the path portion (e.g. "/v1/accounts/12345")
  - `fixture` : name of a JSON file under test/fixtures/td_responses/
  - `status`  : HTTP status to return (default 200)
  """
  def expect_json(bypass, method, path, fixture, status \\ 200) do
    # Strip query string for Bypass path matching (request_path never includes ?query)
    clean_path = path |> String.split("?", parts: 2) |> hd()

    Bypass.expect(bypass, method, clean_path, fn conn ->
      body = load_fixture(fixture)

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(status, body)
    end)
  end

  @doc """
  Loads a fixture file as binary.
  """
  def load_fixture(name) do
    path = Path.join([__DIR__, "..", "fixtures", "td_responses", name])

    case File.read(path) do
      {:ok, content} -> content
      {:error, _} -> raise "Missing fixture: #{path}. Create it under test/fixtures/td_responses/"
    end
  end

  @doc """
  Convenience helper used by all contract tests to build a Client pointed at the current Bypass instance.
  """
  def client_for_bypass(bypass) do
    Client.new(access_token: "demo-token", base_url: "http://localhost:#{bypass.port}")
  end
end
