defmodule POAAgent.Plugins.Collectors.Eth.StatsTest do
  use ExUnit.Case
  import Mock

  test "stats sent to the transfer" do
    with_mock Ethereumex.HttpClient, [
        net_peer_count: fn() -> {:ok, "0x3"} end,
        eth_mining: fn() -> {:ok, false} end,
        eth_hashrate: fn() -> {:ok, "0x0"} end,
        eth_syncing: fn() -> {:ok, syncing()} end,
        eth_gas_price: fn() -> {:ok, "0x0"} end
      ] do

      {:transfer, stats, _} = POAAgent.Plugins.Collectors.Eth.Stats.collect(%{last_stats: nil, tries: 0, down: 0})
      assert stats == expected_stats()
    end
  end

  def syncing() do
    %{
      "currentBlock" => "0x44ee0",
      "highestBlock" => "0x44ee2",
      "startingBlock" => "0x40ad3",
      "warpChunksAmount" => nil,
      "warpChunksProcessed" => nil
    }
  end

  def expected_stats() do
    %POAAgent.Entity.Ethereum.Statistics{
      active?: true,
      gas_price: 0,
      hashrate: 0,
      mining?: false,
      peers: 3,
      syncing?: syncing(),
      uptime: 100.0}
  end
end
