defmodule POAAgent.Entity.Ethereum.History do
  @moduledoc false

  alias POAAgent.Format.POAProtocol.Data
  alias POAAgent.Entity

  @type t :: %__MODULE__{
    history: [POAAgent.Entity.Ethereum.Block.t()]
  }

  defstruct [
    history: []
  ]

  defimpl Data.Format do
    def to_data(x) do
      history = for i <- x.history do
        Entity.NameConvention.from_elixir_to_node(i)
      end
      Data.new("history", %{history: history})
    end
  end
end
