defmodule POAAgent.Entity.Ethereum.Block do
  @moduledoc false
  alias POAAgent.Format.Literal

  @type t :: %__MODULE__{
    author: Literal.Hex.t(),
    difficulty: Literal.Decimal.t(),
    extra_data: Literal.Hex.t(),
    gas_limit: non_neg_integer,
    gas_used: non_neg_integer,
    hash: Literal.Hex.t(),
    miner: Literal.Hex.t(),
    number: non_neg_integer,
    parent_hash: Literal.Hex.t(),
    receipts_root: Literal.Hex.t(),
    seal_fields: [Literal.Hex.t()|[Literal.Hex.t]],
    sha3_uncles: Literal.Hex.t(),
    signature: Literal.TrimmedHex.t(),
    size: non_neg_integer,
    state_root: Literal.Hex.t(),
    step: Literal.Decimal.t(),
    timestamp: pos_integer,
    total_difficulty: Literal.Decimal.t(),
    transactions: [term],
    transactions_root: Literal.Hex.t(),
    uncles: [term]
  }

  defstruct [
    :author,
    :difficulty,
    :extra_data,
    :gas_limit,
    :gas_used,
    :hash,
    :miner,
    :number,
    :parent_hash,
    :receipts_root,
    :seal_fields,
    :sha3_uncles,
    :signature,
    :size,
    :state_root,
    :step,
    :timestamp,
    :total_difficulty,
    :transactions,
    :transactions_root,
    :uncles
  ]
end
