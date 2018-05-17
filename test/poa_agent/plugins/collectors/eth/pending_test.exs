defmodule POAAgent.Plugins.Collectors.Eth.PendingTest do
  use ExUnit.Case

  alias POAAgent.Plugins.Collectors.Eth.Pending

  import Mock

  test "pending data is not sent if it is the same as last pending" do
    echo_transfer = :echo_transfer
    {:ok, _echo} = EchoTransfer.start(echo_transfer)

    args = %{
      name: :eth_pending,
      transfers: [echo_transfer],
      frequency: 500,
      label: :my_metrics,
      args: [url: "http://localhost:8545"]
    }

    with_mock Ethereumex.HttpClient, [
        eth_get_block_transaction_count_by_number: fn(_) -> {:ok, "0x0"} end
      ] do

      {:ok, _pid} = Pending.start_link(args)

      refute_receive {:my_metrics, _}
    end
  end

  test "pending data is sent if it is different than last pending" do
    echo_transfer = :echo_transfer
    {:ok, _echo} = EchoTransfer.start(echo_transfer)

    args = %{
      name: :eth_pending,
      transfers: [echo_transfer],
      frequency: 500,
      label: :my_metrics,
      args: [url: "http://localhost:8545"]
    }

    with_mock Ethereumex.HttpClient, [
        eth_get_block_transaction_count_by_number: fn(_) -> {:ok, "0x3"} end
      ] do

      {:ok, _pid} = Pending.start_link(args)

      assert_receive {:my_metrics,  %POAAgent.Entity.Ethereum.Pending{pending: 3}}, 20_000
    end
  end

  def expected_pending() do
    %POAAgent.Entity.Ethereum.Pending{
      pending: 3
    }
  end
end
