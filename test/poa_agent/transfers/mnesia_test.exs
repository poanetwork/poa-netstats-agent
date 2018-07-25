defmodule POAAgent.Plugins.Transfers.DB.MnesiaTest do
  use ExUnit.Case

  alias POAAgent.Entity.System.Metric
  alias POAAgent.Plugins.Transfers.DB.Mnesia

  test "sending data to mnesia" do
    args = %{name: :metrics_transfer, args: [table_name: :metrics,
                                             fields: [:timestamp, :os_type,
                                                      :unix_process, :cpu_util,
                                                      :disk_used, :memsup]]}

    {:ok, _pid} = Mnesia.start_link(args)

    :ok = send_to_transfer(:metrics_transfer, :my_metrics, data_message())
    Process.sleep(5000)

    read_data = fn -> :mnesia.read({:metrics, 101}) end

    assert {:atomic, [{:metrics, 101, {:unix, :linux}, 101, 10.1, 10,
                      [:ok, 10]}]} = :mnesia.transaction(read_data)
  end

  test "sending more data to DB" do
    args = %{name: :metrics_transfer, args: [table_name: :metrics,
                                             fields: [:timestamp, :os_type,
                                                      :unix_process, :cpu_util,
                                                      :disk_used, :memsup]]}

    {:ok, _pid} = Mnesia.start_link(args)

    :ok = send_to_transfer(:metrics_transfer, :my_metrics, data_message())
    :ok = send_to_transfer(:metrics_transfer, :my_metrics, data_message2())
    Process.sleep(5000)

    read_data = fn -> :mnesia.match_object({:metrics, :_, {:unix, :linux}, 101,
                                            10.1, 10, [:ok, 10]}) end
    assert {:atomic, query} = :mnesia.transaction(read_data)
    assert 2 = Enum.count(query)
  end

  defp send_to_transfer(transfer, label, data) do
    GenServer.cast(transfer, %{label: label, data: data})
  end

  defp data_message() do
    Metric.new(101, {:unix, :linux}, 101, 10.1, 10, [:ok, 10])
  end

  defp data_message2() do
    Metric.new(102, {:unix, :linux}, 101, 10.1, 10, [:ok, 10])
  end
end