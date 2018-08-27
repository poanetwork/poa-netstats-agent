defmodule POAAgent.Entity.System.Statistics do
  @moduledoc false

  alias POAAgent.Format.POAProtocol.Data

  @type t :: %__MODULE__{
    cpu_load: number,
    memory_usage: number,
    disk_usage: number
  }

  defstruct [
    cpu_load: 0,
    memory_usage: 0,
    disk_usage: 0
  ]

  def new(cpu_load, memory_usage, disk_usage) do
    %__MODULE__{
      cpu_load: cpu_load,
      memory_usage: memory_usage,
      disk_usage: disk_usage
    }
  end

  defimpl POAAgent.Entity.NameConvention do
    def from_elixir_to_node(x) do
      Map.from_struct(x)
    end
  end

  defimpl Data.Format do
    def to_data(x) do
      Data.new("statistics", x)
    end
  end
end
