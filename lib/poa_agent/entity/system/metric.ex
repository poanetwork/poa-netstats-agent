defmodule POAAgent.Entity.System.Metric do
  @moduledoc false

  @type t :: %__MODULE__{
    timestamp: integer,
    os_type: {atom, atom},
    unix_process: integer | nil,
    cpu_util: float | nil,
    disk_used: integer,
    memsup: [{atom, integer}]
  }

  defstruct [
    timestamp: nil,
    os_type: nil,
    unix_process: nil,
    cpu_util: nil,
    disk_used: nil,
    memsup: nil
  ]

  @spec new(integer, {atom,atom}, integer | nil, float | nil, integer,
            [{atom, integer}]) :: t
  def new(timestamp, os_type, unix_process, cpu_util, disk_used, memsup) do
    %__MODULE__{
      timestamp: timestamp,
      os_type: os_type,
      unix_process: unix_process,
      cpu_util: cpu_util,
      disk_used: disk_used,
      memsup: memsup
    }
  end
end