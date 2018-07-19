defmodule POAAgen.Plugins.Collectors.System.Metrics do
  use POAAgent.Plugins.Collector

  @moduledoc """
  Nice describe
  """

  @doc false
  @spec init_collector(term()) :: {:ok, none()}
  def init_collector(_args) do
    {:ok, :no_state}
  end

  @doc false
  @spec collect(none()) :: term()
  def collect(:no_state) do
    {:transfer, metrics(), :no_state}
  end

  @doc false
  @spec terminate(term()) :: :ok
  def terminate(_state) do
    :ok
  end

  @doc false
  @spec metrics() :: map()
  defp metrics() do
    %{os_type: :os.type(), unix_process: :cpu_sup.nprocs(),
      cpu_util: :cpu_sup.util(),disk_used: :disksup.get_almost_full_threshold(),
      memsup: :memsup.get_system_memory_data()}
  end

end