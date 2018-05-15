defmodule POAAgent.PluginsTest do
  use ExUnit.Case

  test "__using__ Collector" do
    defmodule Collector1 do
      use POAAgent.Plugins.Collector

      def init_collector(_args) do
        {:ok, :no_state}
      end

      def collect(:no_state) do
        {:transfer, "data retrieved", :no_state}
      end

      def terminate(_state) do
        :ok
      end
    end

    assert Collector1.init(%{frequency: 5_000}) == {:ok, %{internal_state: :no_state, frequency: 5_000}}
    assert Collector1.handle_call(:msg, :from, :state) == {:noreply, :state}
    assert Collector1.handle_info(:msg, :state) == {:noreply, :state}
    assert Collector1.handle_cast(:msg, :state) == {:noreply, :state}
    assert Collector1.code_change(:old, :state, :extra) == {:ok, :state}
    assert Collector1.terminate(:reason, :state) == :ok

  end

  test "__using__ Transfer" do
    defmodule Transfer1 do
      use POAAgent.Plugins.Transfer

      def init_transfer(_args) do
        {:ok, :no_state}
      end

      def data_received(_label, _data, _state) do
        {:ok, :no_state}
      end

      def handle_message(_, state) do
        {:ok, state}
      end

      def terminate(_state) do
        :ok
      end
    end

    assert Transfer1.init(%{args: :args}) == {:ok, %{internal_state: :no_state, args: :args}}
    assert Transfer1.handle_call(:msg, :from, :state) == {:noreply, :state}
    assert Transfer1.handle_cast(:msg, :state) == {:noreply, :state}
    assert Transfer1.code_change(:old, :state, :extra) == {:ok, :state}
    assert Transfer1.terminate(:reason, :state) == :ok

  end

  test "Collector - Transfer integration" do
    defmodule Collector2 do
      use POAAgent.Plugins.Collector

      def init_collector(test_pid) do
        {:ok, test_pid}
      end

      def collect(test_pid) do
        data = "data retrieved"
        send test_pid, {:sent, self(), data}
        {:transfer, data, test_pid}
      end

      def terminate(_state) do
        :ok
      end
    end

    defmodule Transfer2 do
      use POAAgent.Plugins.Transfer

      def init_transfer(test_pid) do
        {:ok, test_pid}
      end

      def data_received(label, data, test_pid) do
        send test_pid, {:received, self(), label, data}
        {:ok, test_pid}
      end

      def handle_message(_, state) do
        {:ok, state}
      end

      def terminate(_state) do
        :ok
      end
    end

    transfer1 = :transfer2

    {:ok, tpid} = Transfer2.start_link(%{name: transfer1, args: self()})
    {:ok, cpid} = Collector2.start_link(%{name: :collector2, transfers: [transfer1], label: :label, args: self(), frequency: 2_000})

    assert_receive {:sent, ^cpid, "data retrieved"}, 20_000
    assert_receive {:received, ^tpid, :label, "data retrieved"}, 20_000

  end
end
