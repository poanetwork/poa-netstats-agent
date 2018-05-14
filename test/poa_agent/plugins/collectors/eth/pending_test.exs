defmodule POAAgent.Plugins.Collectors.Eth.PendingTest do
  use ExUnit.Case
  import Mock

  test "pending data sent to the transfer" do
    with_mock Ethereumex.HttpClient, [
        eth_get_block_transaction_count_by_number: fn(_) -> {:ok, "0x0"} end
      ] do

      {:notransfer, _} = POAAgent.Plugins.Collectors.Eth.Pending.collect(%{last_pending: 0})
    end
    with_mock Ethereumex.HttpClient, [
        eth_get_block_transaction_count_by_number: fn(_) -> {:ok, "0x3"} end
      ] do

      {:transfer, pending, _} = POAAgent.Plugins.Collectors.Eth.Pending.collect(%{last_pending: 0})
      assert pending == expected_pending()
    end
  end

  def expected_pending() do
    %POAAgent.Entity.Ethereum.Pending{
      pending: 3
    }
  end
end
