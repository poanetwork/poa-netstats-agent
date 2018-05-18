defmodule POAAgent.Plugins.Collectors.Eth.StatsTest do
  use ExUnit.Case

  alias POAAgent.Plugins.Collectors.Eth.Stats
  alias POAAgent.Entity.Ethereum.Statistics

  import Mock

  test "stats sent to the transfer when the collectors starts" do
    echo_transfer = :echo_transfer
    {:ok, _echo} = EchoTransfer.start(echo_transfer)

    args = %{
      name: :eth_pending,
      transfers: [echo_transfer],
      frequency: 1000,
      label: :my_metrics,
      args: [url: "http://localhost:8545"]
    }

    with_mock Ethereumex.HttpClient, [
        net_peer_count: fn() -> {:ok, "0x3"} end,
        eth_mining: fn() -> {:ok, false} end,
        eth_hashrate: fn() -> {:ok, "0x0"} end,
        eth_syncing: fn() -> {:ok, syncing()} end,
        eth_gas_price: fn() -> {:ok, "0x0"} end
      ] do
      {:ok, _pid} = Stats.start_link(args)
      expected_stats = expected_stats()

      # received only when starts
      assert_receive {:my_metrics, ^expected_stats}, 20_000
      refute_receive {:my_metrics, _}, 20_000
    end
  end

  test "stats sent to the transfer when the last stats are different" do
    echo_transfer = :echo_transfer
    {:ok, _echo} = EchoTransfer.start(echo_transfer)

    args = %{
      name: :eth_pending,
      transfers: [echo_transfer],
      frequency: 1000,
      label: :my_metrics,
      args: [url: "http://localhost:8545"]
    }

    {:ok, _pid} = Stats.start_link(args)

    with_mock Ethereumex.HttpClient, [
        net_peer_count: fn() -> {:ok, "0x3"} end,
        eth_mining: fn() -> {:ok, false} end,
        eth_hashrate: fn() -> {:ok, "0x0"} end,
        eth_syncing: fn() -> {:ok, syncing()} end,
        eth_gas_price: fn() -> {:ok, "0x0"} end
      ] do
      expected_stats = expected_stats()

      assert_receive {:my_metrics, ^expected_stats}, 20_000
    end
  end

  test "stats sent to the transfer when the node is not active" do
    echo_transfer = :echo_transfer
    {:ok, _echo} = EchoTransfer.start(echo_transfer)

    args = %{
      name: :eth_pending,
      transfers: [echo_transfer],
      frequency: 1000,
      label: :my_metrics,
      args: [url: "http://localhost:8545"]
    }

    with_mock Ethereumex.HttpClient, [
        net_peer_count: fn() -> {:ok, "0x0"} end,
        eth_mining: fn() -> {:ok, false} end,
        eth_hashrate: fn() -> {:ok, "0x0"} end,
        eth_syncing: fn() -> {:ok, syncing()} end,
        eth_gas_price: fn() -> {:ok, "0x0"} end
      ] do

      {:ok, _pid} = Stats.start_link(args)

      expected_stats =
        %Statistics{expected_stats() |
        active?: false,
        peers: 0,
        uptime: 0.0
      }

      assert_receive {:my_metrics, ^expected_stats}, 20_000
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
    %Statistics{
      active?: true,
      gas_price: 0,
      hashrate: 0,
      mining?: false,
      peers: 3,
      syncing?: syncing(),
      uptime: 100.0}
  end
end
