defmodule POAAgen.Plugins.Metrics do
  quote do
    defmacro __uing__(_opt) do
      @behaviour POAAgen.Plugins.Metrics

      @doc false
      def start_link(%{name: name} = state) do
        GenServer.start_link(__MODULE__, state, name: name)
      end

      @doc false
      def init(state) do
        timer_ref = Process.send_after(self(), :collect_metrics, 5000)
        {:ok, %{timer_ref: timer_ref}}
      end

      @doc false
      def handle_call(_msg, _from, state) do
        {:noreply, state}
      end

      @doc false
      def handle_cast(msg, state) do
        {:noreply, state}
      end

      @doc false
      def handle_info(:collect_metrics, state) do
        Process.cancel_timer(state.timer_ref)
        {:noreply, state}
      end

      @doc false
      def code_change(_old, state, _extra) do
        {:ok, state}
      end

      @doc false
      def terminate(_reason, state) do
        terminate(state)
      end

    end
  end
end