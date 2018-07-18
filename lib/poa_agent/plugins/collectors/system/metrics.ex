defmodule POAAgen.Plugins.Collectors.System.Metrics do
  use POAAgent.Plugins.Collector

  @moduledoc """
  Nice describe
  """
  def init_collector(_args) do
    :application.start(:sasl)
    :application.start(:os_mon)
    {:ok, :no_state}
  end

  def collect(:no_state) do
    {:transfer, metrics(), :no_state}
  end

  def terminate(_state) do
    :ok
  end

  defp metrics() do
    unix_process = :cpu_sup.nprocs()
    cpu_util = :cpu_sup.util()
    disk_used = :disksup.get_almost_full_threshold()
    list = [:os.type(), {:unix_process, unix_process}, {cpu_util, cpu_util},
                        {disk_used, disk_used} ]
    Enum.map(:memsup.get_system_memory_data() ++ list, fn {k, v} -> {k, v} end)
  end

end