defmodule POAAgent.Plugins.Collectors.System.Metrics do
  use POAAgent.Plugins.Collector
  alias POAAgent.Entity.System.Metric

  @moduledoc """
  Nice describe
  """

  @type internal_state :: %{last_metrics: Metric}

  @doc false
  @spec init_collector(term()) :: {:ok, internal_state()}
  def init_collector(_args) do
    :application.ensure_all_started(:os_mon)
    {:ok, %{last_metrics: nil}}
  end

  @doc false
  @spec collect(internal_state()) :: term()
  def collect(%{last_metrics: last_metrics} = state) do
    case metrics() do
      ^last_metrics ->
        {:notransfer, state}
      metrics ->
        {:transfer, metrics, %{last_metrics: metrics}}
    end
  end

  @doc false
  @spec terminate(internal_state()) :: :ok
  def terminate(_state) do
    :ok
  end

  @doc false
  @spec metrics() :: map()
  defp metrics() do
    unix_process = check_metric(:cpu_sup.nprocs())
    cpu_util = check_metric(:cpu_sup.util())
    Metric.new(:os.system_time(), :os.type(), unix_process, cpu_util,
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