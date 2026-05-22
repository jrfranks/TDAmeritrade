# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Stream.LevelOne do
  @moduledoc """
  Legacy Level One (QUOTE) streaming helpers.

  The extensive field tables that used to live here remain valuable reference
  material. The actual implementation is now in `TDAmeritrade.Stream.Real`
  (or `Offline`) + `TDAmeritrade.Stream.Parsers` (which turns numeric fields
  into friendly atoms such as `:bid_price`, `:last_price`, etc.).
  """

  @doc """
  Legacy no-op. Use the modern streaming API.
  """
  def level_one() do
    IO.warn(
      "TDAmeritrade.level_one/0 (and TDAmeritrade.Stream.LevelOne) is deprecated. " <>
        "Prefer TDAmeritrade.Stream.Real.subscribe(streamer, \"LEVELONE_EQUITY\", keys, fields)"
    )

    :ok
  end

  defmacro __using__(_) do
    quote do
      def level_one() do
        try do
          TDAmeritrade.Stream.LevelOne.level_one()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
