# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Stream.Admin do
  @moduledoc """
  Legacy ADMIN streaming helpers.

  The rich protocol documentation that used to live here is still accurate
  and is now primarily served by `TDAmeritrade.Stream.Commands`,
  `TDAmeritrade.Stream.Parsers`, `TDAmeritrade.Stream.Real`, and
  `TDAmeritrade.Stream.Offline`.
  """

  @doc """
  Legacy no-op. Use the modern streaming API instead.
  """
  def admin() do
    IO.warn(
      "TDAmeritrade.admin/0 (and TDAmeritrade.Stream.Admin) is deprecated. " <>
        "Use TDAmeritrade.Stream.Real or TDAmeritrade.Stream.Offline for streaming."
    )

    :ok
  end

  defmacro __using__(_) do
    quote do
      def admin() do
        try do
          TDAmeritrade.Stream.Admin.admin()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
