defmodule POAAgent.Entity.Ethereum.Statistics do
  @moduledoc false
  alias POAAgent.Format.Literal

  @type t :: %__MODULE__{
    active?: boolean,
    mining?: boolean,
    hashrate: non_neg_integer,
    peers: non_neg_integer,
    gas_price: Literal.Decimal.t(),
    syncing?: boolean,
    uptime: non_neg_integer
  }

  defstruct [
    active?: nil,
    mining?: nil,
    hashrate: nil,
    peers: nil,
    gas_price: nil,
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
      Enum.reduce(mapping, x, &POAAgent.Entity.Name.change/2)
    end
  end
end
