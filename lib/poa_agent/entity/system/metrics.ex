defmodule POAAgent.Entity.System.Metrics do
  @moduledoc false

  @type t :: %__MODULE__{
    os_type: {atom, atom},
    unix_process: integer | nil,
    cpu_util: float | nil,
    disk_used: integer,
    memsup: [{atom, integer}]
  }

  defstruct [
    os_type: nil,
    unix_process: nil,
    cpu_util: nil,
    disk_used: nil,
    memsup: nil
  ]
end