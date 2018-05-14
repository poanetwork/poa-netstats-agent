defmodule POAAgent.Entity.Ethereum.Pending do
  @moduledoc false

  @type t :: %__MODULE__{
    pending: non_neg_integer
  }

  defstruct [
    pending: nil
  ]

end
