defmodule POAAgent.Plugins.Collectors.System.MetricsTest do
  use ExUnit.Case

  alias POAAgent.Plugins.Collectors.System.Metrics
  alias POAAgent.Entity.System.Metric

  import Mock

  test "metrics sent to the transfer when the collectors starts" do
    echo_transfer = :echo_transfer
    {:ok, _echo} = EchoTransfer.start(echo_transfer)
    args = %{
      name: :eth_latest_block,
      transfers: [echo_transfer],
      frequency: 500,
      label: :my_metrics,
      args: [url: "http://localhost:8545"]
    }
    {:ok, _pid} = Metrics.start_link(args)

    assert_receive {:my_metrics, %Metric{os_type: {os_type1, os_type2},
                                          unix_process: unix_process,
                                          cpu_util: cpu_util,
                                          disk_used: disk_used,
                                          memsup: memsup}},
                                          20_000
    assert Enum.member?([:unix, :win32], os_type1)
    assert is_atom(os_type2)
    assert is_integer(unix_process)
    assert is_float(cpu_util)
    assert is_integer(disk_used)
    assert is_list(memsup)
  end

  test "metrics data is sent if it is different than last metrics" do
    echo_transfer = :echo_transfer
    {:ok, _echo} = EchoTransfer.start(echo_transfer)
    args = %{
      name: :eth_latest_block,
      transfers: [echo_transfer],
      frequency: 500,
      label: :my_metrics,
      args: [url: "http://localhost:8545"]
    }

    :application.ensure_all_started(:os_mon)
    with_mocks ([
      # {:os , [], [type: fn() -> {:unix, :linux} end]}, we cannot mock this one
      # {:cpu_sup , [], [nprocs: fn() -> 10 end,    we cannot mock those one too
                     # util: fn() -> 10.0 end]},
      {:disksup , [], [get_almost_full_threshold: fn() -> 10 end]},
      {:memsup , [], [get_system_memory_data: fn() -> [{:ok, 10}] end]}
      ]) do

      {:ok, _pid} = Metrics.start_link(args)

      assert_receive {:my_metrics, %Metric{os_type: _,
                                          unix_process: _,
                                          cpu_util: _,
                                          disk_used: disk_used,
                                          memsup: memsup}},
                                          20_000
      assert disk_used == 10
      assert memsup == [{:ok, 10}]
    end
  end
end