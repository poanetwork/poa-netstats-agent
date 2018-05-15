defmodule POAAgent.Entity.Ethereum.Pending do
  @moduledoc false

  @type t :: %__MODULE__{
    pending: non_neg_integer
  }

  defstruct [
    pending: nil
  ]

  defimpl POAAgent.Entity.NameConvention do
    def from_elixir_to_node(x) do
      Map.from_struct(x)
    end
  end
end
