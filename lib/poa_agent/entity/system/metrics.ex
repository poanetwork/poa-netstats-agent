defmodule POAAgent.Entity.System.Metrics do
  @moduledoc false

  @type t :: %__MODULE__{
    os_type: {unix | win32, atom},
    unix_process: integer | {error, term},
    cpu_util: float | {error, term},
    disk_used: integer,
    memsup: [{atom, integer}]
  }
end