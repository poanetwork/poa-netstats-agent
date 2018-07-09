defmodule POAAgent.Transfers.RestTest do
  use ExUnit.Case

  alias POAAgent.Plugins.Transfers.HTTP.REST
  alias POAAgent.Entity.Ethereum.Block

  import Mock

  test "sending the Ping and Latency messages" do
    args = %{name: :rest_dashboard, args: [address: "localhost", contact: "mymail@gmail.com"]}
    test_pid = self()

    with_mocks([
      {HTTPoison,
       [],
       [
        post: fn(url, event, _) ->
          {:ok, event} = Msgpax.unpack(event)
          send(test_pid, {url, event})
          {:ok, %HTTPoison.Response{status_code: 200}}
        end
        ]},
      {Ethereumex.HttpClient,
      [],
      [
        eth_coinbase: fn() -> {:ok, "0x0"} end,
        eth_protocol_version: fn() -> {:ok, "15"} end,
        web3_client_version: fn() -> {:ok, "0x0"} end,
        net_version: fn() -> {:ok, "0x0"} end
      ]}]) do
      {:ok, _pid} = REST.start_link(args)

      assert_receive {"localhost/data", %{"data" => %{"body" => body}}}, 20_000

      assert Map.has_key?(body, "latency")

      assert_receive {"localhost/ping", _}, 20_000
    end
  end

  test "sending the data message" do
    args = %{name: :rest_dashboard, args: [address: "localhost", contact: "mymail@gmail.com"]}
    test_pid = self()

    with_mock HTTPoison, [
        post: fn(url, event, _) ->
          send(test_pid, {url, event})
          {:ok, %HTTPoison.Response{status_code: 200}}
        end
      ] do
      {:ok, _pid} = REST.start_link(args)

      Process.sleep(500)
      :ok = send_to_transfer(:rest_dashboard, :my_metrics, data_message())

      assert_receive {"localhost/data", _}, 20_000
    end
  end

  test "handling rest errors" do
    args = %{name: :rest_dashboard, args: [address: "localhost", contact: "mymail@gmail.com"]}
    test_pid = self()

    with_mock HTTPoison, [
        post: fn(url, event, _) ->
          send(test_pid, {url, event})
          {:ok, %HTTPoison.Response{status_code: 401}}
        end
      ] do
      {:ok, _pid} = REST.start_link(args)

      # we are not going to receive latency messages
      refute_receive {"localhost/latency", _}, 20_000
    end
  end

  test "handling rest econnrefused" do
    args = %{name: :rest_dashboard, args: [address: "localhost", contact: "mymail@gmail.com"]}
    test_pid = self()

    with_mock HTTPoison, [
        post: fn(url, event, _) ->
          send(test_pid, {url, event})
          {:error, %HTTPoison.Error{reason: "econnrefused"}}
        end
      ] do
      {:ok, _pid} = REST.start_link(args)

      # we are not going to receive latency messages
      refute_receive {"localhost/latency", _}, 20_000
    end
  end

  defp send_to_transfer(transfer, label, data) do
    GenServer.cast(transfer, %{label: label, data: data})
  end

  defp data_message() do
    %Block{}
  end
end