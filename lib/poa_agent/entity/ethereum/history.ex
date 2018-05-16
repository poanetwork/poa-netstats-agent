defmodule POAAgent.Entity.Ethereum.History do
  @moduledoc false

  @type t :: %__MODULE__{
    history: [POAAgent.Entity.Ethereum.Block.t()]
  }

  defstruct [
    :history
  ]
end
