# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  All Rights Reserved.
#                   admin@svelte.works
#
#                 Author: John R. Franks (demo implementation)
# -

defmodule TDAmeritrade.Stream.Legacy do
  @moduledoc false
  # Internal helper to give consistent deprecation messages for the old
  # flat streaming functions that used to live under `use TDAmeritrade`.

  defmacro __using__(opts) do
    fun_name = Keyword.fetch!(opts, :fun)

    quote do
      def unquote(fun_name)() do
        IO.warn(
          "TDAmeritrade.#{unquote(fun_name)}/0 (legacy streaming) is deprecated. " <>
            "Use TDAmeritrade.Stream.Real (live) or TDAmeritrade.Stream.Offline (hermetic) instead. " <>
            "The old per-service modules only contained documentation; the real protocol " <>
            "logic now lives in Commands, Parsers, Real, and Offline."
        )

        :ok
      end

      defmacro __using__(_) do
        fun = unquote(fun_name)

        quote do
          def unquote(fun)() do
            try do
              unquote(__MODULE__).unquote(fun)()
            rescue
              e -> {:error, e}
            end
          end
        end
      end
    end
  end
end
