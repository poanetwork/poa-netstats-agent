defmodule POAAgent.Entity.Ethereum.Statistics do
  @moduledoc false
  alias POAAgent.Format.Literal

  @type t :: %__MODULE__{
    active?: boolean,
    mining?: boolean,
    hashrate: non_neg_integer,
    peers: non_neg_integer,
    pending: non_neg_integer,
    gas_price: Literal.Decimal.t(),
    block: POAAgent.Entity.Ethereum.Block.t(),
    syncing?: boolean,
    uptime: non_neg_integer
  }

  defstruct [
    :active?,
    :mining?,
    :hashrate,
    :peers,
    :pending,
    :gas_price,
    :block,
    :syncing?,
    :uptime
  ]
end
