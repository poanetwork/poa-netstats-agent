defmodule POAAgent.Plugins.Collectors.System.StatsTest do
  use ExUnit.Case

  alias POAAgent.Plugins.Collectors.System.Stats
  alias POAAgent.Entity.System.Statistics

  test "sending stats to the transfer when the collector starts and after a while" do
    echo_transfer = :echo_transfer
    {:ok, _echo} = EchoTransfer.start(echo_transfer)

    args = %{
      name: :system_metrics,
      transfers: [echo_transfer],
      frequency: 1000,
      label: :system_metrics,
      args: []
    }

    {:ok, _pid} = Stats.start_link(args)

    assert_receive {:system_metrics, metric}, 20_000
    assert %Statistics{cpu_load: cpu_load, memory_usage: memory_usage, disk_usage: disk_usage} = metric
    assert is_number(cpu_load)
    assert is_number(memory_usage)
    assert is_number(disk_usage)

    # we should receiver system metrics again
    assert_receive {:system_metrics, metric}, 20_000
    assert %Statistics{cpu_load: cpu_load, memory_usage: memory_usage, disk_usage: disk_usage} = metric
    assert is_number(cpu_load)
    assert is_number(memory_usage)
    assert is_number(disk_usage)
  end
end