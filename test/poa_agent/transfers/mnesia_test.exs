defmodule POAAgent.Plugins.Transfers.DB.MnesiaTest do
  use ExUnit.Case

  # alias POAAgent.Entity.System.Metric
  alias POAAgent.Plugins.Transfers.DB.Mnesia

  import Mock

  test "sending data to mnesia" do
    args = %{name: :metrics, args: []}

    with_mocks ([{:disksup , [], [get_almost_full_threshold: fn() -> 10 end]},
            {:memsup , [], [get_system_memory_data: fn() -> [{:ok, 10}] end]}
      ]) do

      {:ok, _pid} = Mnesia.start_link(args)

      Process.sleep(5000)

      read_data = fn -> :mnesia.read({:metrics}) end

      assert {:atomic, [:metrics, _, _, _, disk_used,
                        memsup]} = :mnesia.transaction(read_data)
      assert disk_used == 10
      assert memsup == [{:ok, 10}]
    end
  end
end