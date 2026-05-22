
defmodule TDAmeritrade.Types.Transaction do
  @moduledoc """
  %{
    "Transaction" => [
      {"properties",
       [
         {"accruedInterest", [{"format", "double"}, {"type", "number"}]},
         {"achStatus",
          [{"enum", ["Approved", "Rejected", "Cancel", "Error"]}, {"type", "string"}]},
         {"cashBalanceEffectFlag", [{"default", false}, {"type", "boolean"}]},
         {"clearingReferenceNumber", [{"type", "string"}]},
         {"dayTradeBuyingPowerEffect", [{"format", "double"}, {"type", "number"}]},
         {"description", [{"type", "string"}]},
         {"fees",
          [
            {"additionalProperties", [{"format", "double"}, {"type", "number"}]},
            {"type", "object"}
          ]},
         {"netAmount", [{"format", "double"}, {"type", "number"}]},
         {"orderDate", [{"format", "date-time"}, {"type", "string"}]},
         {"orderId", [{"type", "string"}]},
         {"requirementReallocationAmount", [{"format", "double"}, {"type", "number"}]},
         {"settlementDate", [{"format", "date-time"}, {"type", "string"}]},
         {"sma", [{"format", "double"}, {"type", "number"}]},
         {"subAccount", [{"type", "string"}]},
         {"transactionDate", [{"format", "date-time"}, {"type", "string"}]},
         {"transactionId", [{"format", "int64"}, {"type", "integer"}]},
         {"transactionItem", [{"$dict", "TransactionItem"}]},
         {"transactionSubType", [{"type", "string"}]},
         {"type",
          [
            {"enum",
             [
               "TRADE",
               "RECEIVE_AND_DELIVER",
               "DIVIDEND_OR_INTEREST",
               "ACH_RECEIPT",
               "ACH_DISBURSEMENT",
               "CASH_RECEIPT",
               "CASH_DISBURSEMENT",
               "ELECTRONIC_FUND",
               "WIRE_OUT",
               "WIRE_IN",
               "JOURNAL",
               "MEMORANDUM",
               "MARGIN_CALL",
               "MONEY_MARKET",
               "SMA_ADJUSTMENT"
             ]},
            {"type", "string"}
          ]}
       ]},
      {"type", "object"}
    ]
  }
  """

  @typedoc """

  """
  @type t :: binary() | String.t()

  @doc """
  ## Examples
    iex> TDAmeritrade.Types.Transaction.is_valid?(%{})
    false
    iex> TDAmeritrade.Types.Transaction.is_valid?(x)
    true
  """
  @spec is_valid?(t) :: boolean()
  def is_valid?(transaction) when map_size(transaction) == 0, do: true
  def is_valid?(transaction) when is_map(transaction), do: true
  def is_valid?(_transaction), do: false
end
