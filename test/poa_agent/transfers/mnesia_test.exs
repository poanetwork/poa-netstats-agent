defmodule POAAgent.Plugins.Transfers.DB.MnesiaTest do
  use ExUnit.Case

  alias POAAgent.Entity.System.Metric
  alias POAAgent.Plugins.Transfers.DB.Mnesia

  test "sending data to mnesia" do
    args = %{name: :metrics_transfer, args: []}

    {:ok, _pid} = Mnesia.start_link(args)

    :ok = send_to_transfer(:metrics_transfer, :my_metrics, data_message())
    Process.sleep(5000)

    read_data = fn -> :mnesia.read({:metrics, 101}) end

    assert {:atomic, [{:metrics, 101, {:unix, :linux}, 101, 10.1, 10, [:ok, 10]}]} = :mnesia.transaction(read_data)
  end

  defp send_to_transfer(transfer, label, data) do
    GenServer.cast(transfer, %{label: label, data: data})
  end

  defp data_message() do
    Metric.new(101, {:unix, :linux}, 101, 10.1, 10, [:ok, 10])
  end
end
