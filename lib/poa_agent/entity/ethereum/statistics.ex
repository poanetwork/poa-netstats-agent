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
    active?: nil,
    mining?: nil,
    hashrate: nil,
    peers: nil,
    pending: nil,
    gas_price: nil,
    block: %POAAgent.Entity.Ethereum.Block{},
    syncing?: nil,
    uptime: nil
  ]

  defimpl POAAgent.Entity.NameConvention do
    def from_elixir_to_node(x) do
      mapping = [
        active?: :active,
        mining?: :mining,
        gas_price: :gasPrice,
        syncing?: :syncing
      ]
      x = Enum.reduce(mapping, x, &POAAgent.Entity.Name.change/2)
      Map.update!(x, :block, &POAAgent.Entity.NameConvention.from_elixir_to_node/1)
    end
  end
end
