defmodule POAAgent.Plugins.Collectors.System.Stats do
  use POAAgent.Plugins.Collector

  @moduledoc """
  This module retrieves system metrics. Those metrics are the cpu usage, memory and disk.
  In order to use it we have to add it to the config file like this:

      {:system_collector, POAAgent.Plugins.Collectors.System.Stats, 60_000, :system_metrics, []}

  In this example we are checking the system metrics every minute

  """

  alias POAAgent.Entity.System.Statistics

  @typep internal_state :: %{
    last_metrics: Statistics.t
  }

  @doc false
  @spec init_collector(term()) :: {:ok, internal_state()}
  def init_collector(_) do
    stats = gather_metrics()

    {:transfer, stats, %{last_metrics: stats}}
  end

  @doc false
  @spec collect(internal_state()) :: term()
  def collect(%{last_metrics: last_metrics} = state) do
    case gather_metrics() do
      ^last_metrics ->
        {:notransfer, state}
      metrics ->
        {:transfer, metrics, %{state | last_metrics: metrics}}
    end
  end

  @doc false
  @spec metric_type() :: String.t
  def metric_type do
    "system_metrics"
  end

  @doc false
  @spec terminate(internal_state()) :: :ok
  def terminate(_state) do
    :ok
  end

  defp gather_metrics() do
    Statistics.new(cpu_load(), memory_usage(), disk_usage())
  end

  defp cpu_load do
    {total, amount} =
      case :cpu_sup.util([:per_cpu]) do
        cpu_info when is_list(cpu_info) ->
          cpu_info
          |> Enum.reduce({0, 0}, fn({_, load, _, _}, {total, acc}) ->
                                   {total + 100.0, acc + load}
                                 end)
        _ ->
          {100, 0}
      end

    percentage(total, amount)
  end

  defp memory_usage do
    memory = :memsup.get_system_memory_data()

    {total, amount} =
      case Keyword.get(memory, :total_memory) do
        nil ->
          {100, 0}
        total_memory ->
          {total_memory, :erlang.memory(:total)}
      end

    percentage(total, amount)
  end

  defp disk_usage do
    [{_, _, usage} | _] = :disksup.get_disk_data() |> Enum.sort(&(elem(&1, 2) >= elem(&2, 2)))
    usage
  end

  defp percentage(total, amount) do
    100 * amount / total
  end

end