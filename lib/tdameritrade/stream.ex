# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Stream do
  @moduledoc """
  Legacy streaming entry point.

  The modern streaming API lives in `TDAmeritrade.Stream.Real` (live WebSocket)
  and `TDAmeritrade.Stream.Offline` (hermetic simulator for tests/demos).

  The functions below are preserved for backward compatibility with code that
  does `use TDAmeritrade`.
  """

  @doc """
  Legacy function. Consider using `TDAmeritrade.Stream.Real` or `Offline` instead.
  """
  def create() do
    IO.warn(
      "TDAmeritrade.Stream.create/0 is deprecated. Use TDAmeritrade.Stream.Real.start_link/1 or TDAmeritrade.Stream.Offline.start_link/1 instead."
    )

    {:ok, :use_new_stream_api}
  end

  @doc """
  Legacy function.
  """
  def destroy() do
    IO.warn("TDAmeritrade.Stream.destroy/0 is deprecated.")
    :ok
  end

  defmacro __using__(_) do
    quote do
      def create() do
        try do
          TDAmeritrade.Stream.create()
        rescue
          e -> {:error, e}
        end
      end

      def destroy() do
        try do
          TDAmeritrade.Stream.destroy()
        rescue
          e -> {:error, e}
        end
      end
    end
  end
end
