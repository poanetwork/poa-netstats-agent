defmodule POAAgent.Plugins.Collectors.System.MetricsTest do
  use ExUnit.Case

  test "__using__ Collector" do
    defmodule Metrics1 do
      use POAAgent.Plugins.Collector

      def init_collector(_args) do
        {:ok, :no_state}
      end

      def collect(:no_state) do
        {:transfer, "data metrics", :no_state}
      end

      def terminate(_state) do
        :ok
      end
    end

    assert Metrics1.init(%{frequency: 5_000}) == {:ok, %{internal_state: :no_state, frequency: 5_000}}
    assert Metrics1.handle_call(:msg, :from, :state) == {:noreply, :state}
    assert Metrics1.handle_cast(:msg, :state) == {:noreply, :state}
    assert Metrics1.code_change(:old, :state, :extra) == {:ok, :state}
    assert Metrics1.terminate(:reason, :state) == :ok

  end
end