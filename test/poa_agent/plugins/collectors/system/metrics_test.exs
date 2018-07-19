defmodule POAAgent.Plugins.Collectors.System.MetricsTest do
  use ExUnit.Case

  alias POAAgent.Plugins.Collectors.System.Metrics

  test "testing" do
    echo_transfer = :echo_transfer
    {:ok, _echo} = EchoTransfer.start(echo_transfer)

    assert_receive {:my_metrics, %Metrics{os_type: os_type,
                                          unix_process: nprocs, cpu_util: util,
                                          disk_used: disksup, memsup: memsup}},
                                          20_000
    # assert os_type
    assert nprocs 
    # assert util
    # assert disksup
    # assert memsup
  end
  #   args = %{
  #     name: :eth_pending,
  #     transfers: [echo_transfer],
  #     frequency: 500,
  #     label: :my_metrics,
  #     args: [url: "http://localhost:8545"]
  #   }
  #   {:ok, _pid} = Metrics.start(echo_transfer)
  #   expected_metrics = expected_metrics(args)

  #   assert_receive {:my_metrics, ^expected_metrics}, 20_000
  # end

  # def expected_metrics() do
  #   %Metrics{
  #     os_type: {atom, atom},
  #     unix_process: integer,
  #     cpu_util: float,
  #     disk_used: integer,
  #     memsup: [{atom, integer}]}
  # end
end