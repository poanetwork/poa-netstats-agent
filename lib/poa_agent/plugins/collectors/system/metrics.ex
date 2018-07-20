defmodule POAAgent.Plugins.Collectors.System.Metrics do
  use POAAgent.Plugins.Collector
  alias POAAgent.Entity.System.Metric

  @moduledoc """
  Nice describe
  """

  @doc false
  @spec init_collector(term()) :: {:ok, none()}
  def init_collector(_args) do
    :application.ensure_all_started(:os_mon)
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
    unix_process = check_metric(:cpu_sup.nprocs())
    cpu_util = check_metric(:cpu_sup.util())
    Metric.new(:os.type(), unix_process, cpu_util,
               :disksup.get_almost_full_threshold(),
               :memsup.get_system_memory_data())
  end

  @doc false
  @spec check_metric(integer | float | {atom, atom}) :: integer | float | nil
  defp check_metric(metric) do
    case metric do
      {error, _Reason} ->
        nil
      _ ->
        metric
    end
  end
end