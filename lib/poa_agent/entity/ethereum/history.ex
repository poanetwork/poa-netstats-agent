defmodule POAAgent.Entity.Ethereum.History do
  @moduledoc false

  alias POAAgent.Format.POAProtocol.Data

  @type t :: %__MODULE__{
    history: [POAAgent.Entity.Ethereum.Block.t()]
  }

  defstruct [
    history: []
  ]

  defimpl Data.Format do
    def to_data(x) do
      history = for i <- x.history do
        Map.from_struct(i)
      end
      Data.new("history", %{history: history})
    end
  end
end
