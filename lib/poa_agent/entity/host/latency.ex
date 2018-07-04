defmodule POAAgent.Entity.Host.Latency do
  @moduledoc false

  alias POAAgent.Format.POAProtocol.Data

  @type t :: %__MODULE__{
    latency: non_neg_integer
  }

  defstruct [
    latency: 0
  ]

  @spec new(non_neg_integer) :: t
  def new(latency) when is_integer(latency) and latency >= 0 do
    %__MODULE__{latency: latency}
  end

  def new(latency) when is_float(latency) do
    latency
    |> round()
    |> new()
  end

  defimpl POAAgent.Entity.NameConvention do
    def from_elixir_to_node(x) do
      Map.from_struct(x)
    end
  end

  defimpl Data.Format do
    def to_data(x) do
      Data.new("latency", x)
    end
  end

end