defmodule POAAgent.Plugins.Collectors.System.MetricsTest do
  use ExUnit.Case

  alias POAAgent.Plugins.Collectors.System.Metrics

  test "testing" do
    echo_transfer = :echo_transfer
    {:ok, _echo} = EchoTransfer.start(echo_transfer)

    args = %{
      name: :eth_pending,
      transfers: [echo_transfer],
      frequency: 500,
      label: :my_metrics,
      args: [url: "http://localhost:8545"]
    }
    {:ok, _pid} = Metrics.start(echo_transfer)
    expected_metrics = expected_metrics(args)

    assert_receive {:my_metrics, ^expected_info}, 20_000
  end

  def expected_metrics() do
    %Metrics{
      os_type: {unix | win32, atom},
      unix_process: integer | {error, term},
      cpu_util: float | {error, term},
      disk_used: integer,
      memsup: [{atom, integer}]
  end
end