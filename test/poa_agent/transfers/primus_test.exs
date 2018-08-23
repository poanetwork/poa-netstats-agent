defmodule POAAgent.Plugins.Collectors.Eth.PrimusTest do
  use ExUnit.Case

  alias POAAgent.Plugins.Transfers.WebSocket.Primus
  alias POAAgent.Entity.Ethereum
  alias Ethereum.Block
  alias Ethereum.Pending
  alias Ethereum.Statistics
  alias Ethereum.History

  import Mock

  test "sending the Hello & Ping messages" do
    args = %{name: :primus_dashboard, args: []}
    test_pid = self()

    with_mocks([
      {WebSockex,
       [],
       [
        send_frame: fn(to, {:text, message}) ->
          send(to, message)
          :ok
        end,
        start_link: fn(_, _, _) -> {:ok, test_pid} end
        ]},
      {Ethereumex.HttpClient,
      [],
      [
        eth_coinbase: fn() -> {:ok, "0x0"} end,
        eth_protocol_version: fn() -> {:ok, "15"} end,
        web3_client_version: fn() -> {:ok, "0x0"} end,
        net_version: fn() -> {:ok, "0x0"} end
      ]}]) do
      {:ok, _pid} = Primus.start_link(args)

      assert_receive "{\"emit\":[\"hello\"" <> _, 20_000
      assert_receive "{\"emit\":[\"node-ping\"" <> _, 20_000
    end
  end

  @tag timeout: 500 + 60_500
  test "sending the information (hello) messages more than once" do
    args = %{name: :primus_dashboard, args: []}
    test_pid = self()

    with_mocks([
      {WebSockex,
       [],
       [
        send_frame: fn(to, {:text, message}) ->
          send(to, message)
          :ok
        end,
        start_link: fn(_, _, _) -> {:ok, test_pid} end
        ]},
      {Ethereumex.HttpClient,
      [],
      [
        eth_coinbase: fn() -> {:ok, "0x0"} end,
        eth_protocol_version: fn() -> {:ok, "15"} end,
        web3_client_version: fn() -> {:ok, "0x0"} end,
        net_version: fn() -> {:ok, "0x0"} end
      ]}]) do
      {:ok, _pid} = Primus.start_link(args)

      delta = 500
      assert_receive "{\"emit\":[\"hello\"" <> _, delta
      assert_receive "{\"emit\":[\"hello\"" <> _, 60_000 + delta
    end
  end

  @tag timeout: 500 + 60_500
  test "information messages change to reflect node changes" do
    args = %{name: :primus_dashboard, args: []}
    test_pid = self()

    with_mocks([
      {WebSockex,
       [],
       [
        send_frame: fn(to, {:text, message}) ->
          send(to, message)
          :ok
        end,
        start_link: fn(_, _, _) -> {:ok, test_pid} end
        ]},
      {Ethereumex.HttpClient,
      [],
      [
        eth_coinbase: fn() -> {:ok, "0x0"} end,
        eth_protocol_version: fn() -> {:ok, "15"} end,
        web3_client_version: fn() -> {:ok, "0x0" <> Float.to_string(:rand.uniform())} end,
        net_version: fn() -> {:ok, "0x0"} end
      ]}]) do
      {:ok, _pid} = Primus.start_link(args)

      assert_receive x = "{\"emit\":[\"hello\"" <> _, :infinity
      assert_receive y = "{\"emit\":[\"hello\"" <> _, :infinity
      assert x != y
    end
  end

  test "sending the stats message" do
    args = %{name: :primus_dashboard, args: []}
    test_pid = self()

    with_mock WebSockex, [
        send_frame: fn(to, {:text, message}) ->
          send(to, message)
          :ok
        end,
        start_link: fn(_, _, _) -> {:ok, test_pid} end
      ] do
      {:ok, _pid} = Primus.start_link(args)

      Process.sleep(500)
      :ok = send_to_transfer(:primus_dashboard, :my_metrics, stats_message())

      assert_receive "{\"emit\":[\"stats\"" <> _, 20_000
    end
  end

  test "sending the last block message" do
    args = %{name: :primus_dashboard, args: []}
    test_pid = self()

    with_mock WebSockex, [
        send_frame: fn(to, {:text, message}) ->
          send(to, message)
          :ok
        end,
        start_link: fn(_, _, _) -> {:ok, test_pid} end
      ] do
      {:ok, _pid} = Primus.start_link(args)

      Process.sleep(500)
      :ok = send_to_transfer(:primus_dashboard, :my_metrics, last_block_message())

      assert_receive "{\"emit\":[\"block\"" <> _, 20_000
      assert_receive "{\"emit\":[\"history\"" <> _, 20_000

      # send a second block won't send the history
      :ok = send_to_transfer(:primus_dashboard, :my_metrics, last_block_message())

      assert_receive "{\"emit\":[\"block\"" <> _, 20_000
      refute_receive "{\"emit\":[\"history\"" <> _, 20_000
    end
  end

  test "sending the history message" do
    args = %{name: :primus_dashboard, args: []}
    test_pid = self()

    with_mock WebSockex, [
        send_frame: fn(to, {:text, message}) ->
          send(to, message)
          :ok
        end,
        start_link: fn(_, _, _) -> {:ok, test_pid} end
      ] do
      {:ok, _pid} = Primus.start_link(args)

      Process.sleep(500)
      :ok = send_to_transfer(:primus_dashboard, :my_metrics, history_message())

      assert_receive "{\"emit\":[\"history\"" <> _, 20_000
    end
  end

  test "sending the pending trx message" do
    args = %{name: :primus_dashboard, args: []}
    test_pid = self()

    with_mock WebSockex, [
        send_frame: fn(to, {:text, message}) ->
          send(to, message)
          :ok
        end,
        start_link: fn(_, _, _) -> {:ok, test_pid} end
      ] do
      {:ok, _pid} = Primus.start_link(args)

      Process.sleep(500)
      :ok = send_to_transfer(:primus_dashboard, :my_metrics, pending_message())

      assert_receive "{\"emit\":[\"pending\"" <> _, 20_000
    end
  end

  test "handle WS reconnections when connection breaks" do
    args = %{name: :primus_dashboard, args: []}
    test_pid = self()

    with_mock WebSockex, [
        send_frame: fn(to, {:text, message}) ->
          send(to, message)
          :ok
        end,
        start_link: fn(_, _, _) -> {:ok, test_pid} end
      ] do
      {:ok, primus_pid} = Primus.start_link(args)

      Process.sleep(500)
      send(primus_pid, {:EXIT, :pid, :econnrefused})

      assert_receive "{\"emit\":[\"hello\"" <> _, 20_000
      assert_receive "{\"emit\":[\"node-ping\"" <> _, 20_000
    end
  end

  test "handle collector's messages when the Transfer is not connected to the Server" do
    args = %{name: :primus_dashboard, args: []}
    test_pid = self()

    with_mock WebSockex, [
        send_frame: fn(_, {:text, message}) ->
          send(test_pid, message)
          :ok
        end,
        start_link: fn(_, _, _) -> {:error, :econnrefused} end
      ] do
      {:ok, _pid} = Primus.start_link(args)

      Process.sleep(500)
      :ok = send_to_transfer(:primus_dashboard, :my_metrics, last_block_message())

      refute_receive "{\"emit\":[\"block\"" <> _, 20_000
    end
  end

  test "handle pong message from the dashboard" do
    message = "{\"emit\":[\"node-pong\",{\"clientTime\":1526597561638,\"serverTime\":1526597561638}]}"

    {:reply, {:text, "{\"emit\":[\"latency\"" <> _}, _} = Primus.Client.handle_frame({:text, message}, %{identifier: 1})
  end

  test "handle history message from the dashboard" do
    with_mock Ethereumex.HttpClient, [
        eth_get_block_by_number: fn(_, _) -> {:ok, ethereumex_block()} end
      ] do
      message = "{\"emit\":[\"history\",{\"max\":5,\"min\":1}]}"
      
      {:reply, {:text, "{\"emit\":[\"history\"" <> _}, _} = Primus.Client.handle_frame({:text, message}, %{identifier: 1})
    end
  end

  test "handle unexpected messages from the dashboard" do
    message = "{\"emit\":[\"unexpected\",{\"clientTime\":1526597561638,\"serverTime\":1526597561638}]}"

    {:ok, :state} = Primus.Client.handle_frame({:text, message}, :state)

    message = "{\"unexpected\":\"message\"}"

    {:ok, :state} = Primus.Client.handle_frame({:text, message}, :state)
    {:ok, :state} = Primus.Client.handle_frame({:other, message}, :state)
  end

  defp send_to_transfer(transfer, label, data) do
    GenServer.cast(transfer, %{label: label, metric_type: "my_metric_type", data: data})
  end

  defp last_block_message() do
    %Block{
      author: "0xdf9c9701e434c5c9f755ef8af18d6a4336550206",
      difficulty: "340282366920938463463374607431768211453",
      extra_data: "0xd583010a008650617269747986312e32342e31826c69",
      gas_limit: 8_000_000,
      gas_used: 0,
      hash: "0xf974c07ac165f8490ef225d47f24b81161e2f2bd8ffd5b926a1a37bb22a02462",
      miner: "0xdf9c9701e434c5c9f755ef8af18d6a4336550206",
      number: 243_673,
      parent_hash: "0xaf6f3c960045aea9edda21e119984028211f4eb3233700c18efca4f8e4c0c2fc",
      receipts_root: "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
      seal_fields: ["0x841230dcf5", "0xb841b5ebbb6d5ff185598a86d5e96d9a238ed020b239e94eb1219a6ce1e425c7f23b768ce411474e935c2e3ee61f812ded702e1b7ca2d1c41ab4053f4420440b651901"],
      sha3_uncles: "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
      signature: "b5ebbb6d5ff185598a86d5e96d9a238ed020b239e94eb1219a6ce1e425c7f23b768ce411474e935c2e3ee61f812ded702e1b7ca2d1c41ab4053f4420440b651901",
      size: 579,
      state_root: "0x590452386894d2ff6ec146a23f61fd0f459259bf0e20c59504c7f2fa3e4feeb1",
      step: "305192181",
      timestamp: 1_525_960_905,
      total_difficulty: "82917625194725838207510880716721255084813106",
      transactions: [],
      transactions_root: "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
      uncles: []
    }
  end

  defp pending_message() do
    %Pending{
      pending: 3
    }
  end

  defp stats_message() do
    %Statistics{
      active?: true,
      gas_price: 0,
      hashrate: 0,
      mining?: false,
      peers: 3,
      syncing?: syncing(),
      uptime: 100.0}
  end

  defp syncing() do
    %{
      "currentBlock" => "0x44ee0",
      "highestBlock" => "0x44ee2",
      "startingBlock" => "0x40ad3",
      "warpChunksAmount" => nil,
      "warpChunksProcessed" => nil
    }
  end

  defp history_message() do
    %History{history: []}
  end

  defp ethereumex_block() do
    %{"author" => "0xdf9c9701e434c5c9f755ef8af18d6a4336550206",
      "difficulty" => "0xfffffffffffffffffffffffffffffffd",
      "extraData" => "0xd583010a008650617269747986312e32342e31826c69",
      "gasLimit" => "0x7a1200",
      "gasUsed" => "0x0",
      "hash" =>
      "0xf974c07ac165f8490ef225d47f24b81161e2f2bd8ffd5b926a1a37bb22a02462",
      "miner" => "0xdf9c9701e434c5c9f755ef8af18d6a4336550206",
      "number" => "0x3b7d9",
      "parentHash" => "0xaf6f3c960045aea9edda21e119984028211f4eb3233700c18efca4f8e4c0c2fc",
      "receiptsRoot" => "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
      "sealFields" => ["0x841230dcf5", "0xb841b5ebbb6d5ff185598a86d5e96d9a238ed020b239e94eb1219a6ce1e425c7f23b768ce411474e935c2e3ee61f812ded702e1b7ca2d1c41ab4053f4420440b651901"],
      "sha3Uncles" => "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
      "signature" => "b5ebbb6d5ff185598a86d5e96d9a238ed020b239e94eb1219a6ce1e425c7f23b768ce411474e935c2e3ee61f812ded702e1b7ca2d1c41ab4053f4420440b651901",
      "size" => "0x243",
      "stateRoot" => "0x590452386894d2ff6ec146a23f61fd0f459259bf0e20c59504c7f2fa3e4feeb1",
      "step" => "305192181",
      "timestamp" => "0x5af450c9",
      "totalDifficulty" => "0x3b7d8ffffffffffffffffffffffffedcd6b32", "transactions" => [],
      "transactionsRoot" => "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
      "uncles" => []}
  end
end
