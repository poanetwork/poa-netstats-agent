defmodule POAAgent.Plugins.Collectors.Eth.InformationTest do
  use ExUnit.Case

  alias POAAgent.Plugins.Collectors.Eth
  alias POAAgent.Entity.Host.Information

  import Mock

  test "sending the information when the collector starts and when collecting" do
    echo_transfer = :echo_transfer
    {:ok, _echo} = EchoTransfer.start(echo_transfer)

    args = %{
      name: :eth_latest_block,
      transfers: [echo_transfer],
      frequency: 1000,
      label: :my_metrics,
      args: [url: "http://localhost:8545",
             name: "nodename",
             contact: "myemail@gmail.com"
            ]
    }

    with_mock Ethereumex.HttpClient, [
        eth_coinbase: fn() -> {:ok, "coinbase"} end,
        eth_protocol_version: fn() -> {:ok, "12"} end,
        web3_client_version: fn() -> {:ok, "node"} end,
        net_version: fn() -> {:ok, "1.2"} end
      ] do
      {:ok, _pid} = Eth.Information.start_link(args)
      expected_info = expected_info_with_eth()

      assert_receive {:my_metrics, ^expected_info}, 20_000
    end
  end

  test "sending the information when the collector starts and when collecting but without eth node up" do
    echo_transfer = :echo_transfer
    {:ok, _echo} = EchoTransfer.start(echo_transfer)

    args = %{
      name: :eth_latest_block,
      transfers: [echo_transfer],
      frequency: 1000,
      label: :my_metrics,
      args: [url: "http://localhost:8545",
             name: "nodename",
             contact: "myemail@gmail.com"
            ]
    }

    {:ok, _pid} = Eth.Information.start_link(args)
    expected_info = expected_info()

    assert_receive {:my_metrics, ^expected_info}, 20_000
  end

  defp expected_info_with_eth() do
    %Information{Information.new() |
          name: "nodename",
          contact: "myemail@gmail.com",
          coinbase: "coinbase",
          protocol: 12,
          node: "node",
          net: "1.2"
      }
  end

  defp expected_info() do
    %Information{Information.new() |
          name: "nodename",
          contact: "myemail@gmail.com"
      }
  end
end