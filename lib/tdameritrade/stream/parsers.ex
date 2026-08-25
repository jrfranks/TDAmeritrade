# +
#           Copyright (c) 2022-2026 SvelteSoft Inc.
#                  Licensed under the MIT License.
#                   admin@svelte.works
#
#                 Author: John R. Franks
# -

defmodule TDAmeritrade.Stream.Parsers do
  @moduledoc """
  Basic parsers for incoming TD Ameritrade streaming messages.

  Converts the raw numeric-field format into more readable Elixir maps.
  """

  @doc """
  Top-level entry point. Dispatches based on the message shape.
  """
  def parse_message(msg) when is_map(msg) do
    cond do
      Map.has_key?(msg, "data") ->
        Map.put(msg, "data", parse_data_messages(msg["data"]))

      Map.has_key?(msg, "response") ->
        Map.put(msg, "response", parse_response_messages(msg["response"]))

      Map.has_key?(msg, "notify") ->
        Map.put(msg, "notify", parse_notify_messages(msg["notify"]))

      Map.has_key?(msg, "snapshot") ->
        Map.put(msg, "snapshot", parse_snapshot_messages(msg["snapshot"]))

      true ->
        msg
    end
  end

  def parse_message(other), do: other

  # --- Data messages (the most common for LEVELONE, CHART, etc.) ---

  defp parse_data_messages(list) when is_list(list) do
    Enum.map(list, &parse_single_data_message/1)
  end

  defp parse_single_data_message(%{"service" => service, "content" => content} = msg) do
    parsed_content = parse_content_for_service(service, content)

    msg
    |> Map.put("content", parsed_content)
    |> Map.put(:service, service)
    |> Map.put(:parsed, true)
  end

  defp parse_single_data_message(other), do: other

  # --- Service-specific content parsers ---

  defp parse_content_for_service("QUOTE", content), do: parse_levelone_quote(content)
  defp parse_content_for_service("LEVELONE_EQUITY", content), do: parse_levelone_quote(content)
  defp parse_content_for_service("CHART_EQUITY", content), do: parse_chart(content)
  defp parse_content_for_service("CHART_FUTURES", content), do: parse_chart(content)
  defp parse_content_for_service("TIMESALE_EQUITY", content), do: parse_timesale(content)
  defp parse_content_for_service("TIMESALE_FUTURES", content), do: parse_timesale(content)
  defp parse_content_for_service("ADMIN", content), do: parse_admin_content(content)

  defp parse_content_for_service(_service, content) when is_list(content) do
    # Generic fallback: convert string keys to atoms where possible.
    # Tolerates both maps and lists of tuples in the content items.
    Enum.map(content, fn item ->
      pairs = if is_map(item), do: Map.to_list(item), else: item

      pairs
      |> Enum.map(fn {k, v} ->
        key = if is_binary(k), do: String.to_atom(k), else: k
        {key, v}
      end)
      |> Map.new()
    end)
  end

  defp parse_content_for_service(_service, content), do: content

  # --- LEVELONE / QUOTE specific parser (most common) ---

  # Field definitions for QUOTE (from level_one.ex documentation)
  @quote_fields %{
    "0" => :symbol,
    "1" => :bid_price,
    "2" => :ask_price,
    "3" => :last_price,
    "4" => :bid_size,
    "5" => :ask_size,
    "6" => :ask_id,
    "7" => :bid_id,
    "8" => :total_volume,
    "9" => :last_size,
    "10" => :trade_time,
    "11" => :quote_time,
    "12" => :high_price,
    "13" => :low_price,
    "14" => :bid_tick,
    "15" => :close_price,
    "16" => :exchange_id,
    "17" => :marginable,
    "18" => :shortable,
    "19" => :last_id,
    "20" => :product,
    "21" => :description,
    "22" => :exchange_name,
    "23" => :open_price,
    "24" => :net_change,
    "25" => :pe_ratio,
    "26" => :div_amount,
    "27" => :div_yield,
    "28" => :nav,
    "29" => :div_date,
    "30" => :is_hard_to_borrow,
    "31" => :is_shortable,
    "key" => :key,
    "delayed" => :delayed
  }

  defp parse_levelone_quote(content) when is_list(content) do
    Enum.map(content, fn item ->
      item
      |> Enum.map(fn {field_id, value} ->
        key = Map.get(@quote_fields, field_id, String.to_atom(field_id))
        {key, value}
      end)
      |> Map.new()
    end)
  end

  defp parse_levelone_quote(other), do: other

  # --- CHART parser ---

  @chart_fields %{
    "0" => :key,
    "1" => :chart_time,
    "2" => :open_price,
    "3" => :high_price,
    "4" => :low_price,
    "5" => :close_price,
    "6" => :volume
  }

  defp parse_chart(content) when is_list(content) do
    Enum.map(content, fn item ->
      item
      |> Enum.map(fn {field_id, value} ->
        key = Map.get(@chart_fields, field_id, String.to_atom(field_id))
        {key, value}
      end)
      |> Map.new()
    end)
  end

  defp parse_chart(other), do: other

  # --- TIMESALE parser ---

  @timesale_fields %{
    "0" => :key,
    "1" => :trade_time,
    "2" => :last_price,
    "3" => :last_size,
    "4" => :last_sequence
  }

  defp parse_timesale(content) when is_list(content) do
    Enum.map(content, fn item ->
      item
      |> Enum.map(fn {field_id, value} ->
        key = Map.get(@timesale_fields, field_id, String.to_atom(field_id))
        {key, value}
      end)
      |> Map.new()
    end)
  end

  defp parse_timesale(other), do: other

  # --- ADMIN content parser (for "data" style, usually not used for ADMIN) ---

  defp parse_admin_content(content) when is_list(content) do
    Enum.map(content, fn item ->
      item
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
      |> Map.new()
    end)
  end

  defp parse_admin_content(other), do: other

  # --- Response messages (LOGIN, LOGOUT, QOS, etc.) ---

  defp parse_response_messages(list) when is_list(list) do
    Enum.map(list, &parse_single_response/1)
  end

  defp parse_single_response(%{"service" => "ADMIN"} = item) do
    parse_admin_response(item)
  end

  defp parse_single_response(other), do: other

  # --- ADMIN Response parser (LOGIN, LOGOUT, QOS) ---

  defp parse_admin_response(%{"command" => command, "content" => content} = item) do
    parsed_content = parse_admin_command_response(command, content)

    item
    |> Map.put("content", parsed_content)
    |> Map.put(:parsed, true)
  end

  defp parse_admin_response(other), do: other

  defp parse_admin_command_response("LOGIN", %{"code" => code, "msg" => msg}) do
    %{
      success: code == 0,
      code: code,
      msg: msg,
      reason: if(code == 0, do: nil, else: msg)
    }
  end

  defp parse_admin_command_response("LOGOUT", %{"code" => code, "msg" => msg}) do
    %{
      success: code == 0,
      code: code,
      msg: msg
    }
  end

  defp parse_admin_command_response("QOS", %{"code" => code, "msg" => msg}) do
    %{
      success: code == 0,
      code: code,
      msg: msg
    }
  end

  defp parse_admin_command_response(_command, content) when is_map(content) or is_list(content) do
    pairs = if is_map(content), do: Map.to_list(content), else: content

    pairs
    |> Enum.map(fn {k, v} ->
      key = if is_binary(k), do: String.to_atom(k), else: k
      {key, v}
    end)
    |> Map.new()
  end

  defp parse_admin_command_response(_command, content), do: content

  # --- Notify / Snapshot (basic passthrough for now) ---

  defp parse_notify_messages(list) when is_list(list), do: list
  defp parse_snapshot_messages(list) when is_list(list), do: list
end
