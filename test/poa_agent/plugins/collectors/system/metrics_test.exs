defmodule POAAgent.Plugins.Collectors.System.MetricsTest do
  use ExUnit.Case

  alias POAAgent.Plugins.Collectors.System.Metrics
  alias POAAgent.Entity.System.Metric

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
    # assert is_atom(os_type1)
    assert Enum.member?([:unix, :win32], os_type1)
    assert is_atom(os_type2)
    assert is_integer(unix_process)
    assert is_float(cpu_util)
    assert is_integer(disk_used)
    assert is_list(memsup)
  end
end