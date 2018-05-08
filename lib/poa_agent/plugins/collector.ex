defmodule POAAgent.Plugins.Collector do

  @callback init_collector(args :: term()) ::
      {:ok, any()}

  @callback collect(state :: any()) :: {:ok, data :: any(), state :: any()}

  @callback terminate(state :: term()) :: term()

  defmacro __using__(_opt) do
    quote do
      @behaviour POAAgent.Plugins.Collector

      @doc false
      def start_link(%{name: name} = state) do
        GenServer.start_link(__MODULE__, state, name: name)
      end

      @doc false
      def init(state) do
        {:ok, internal_state} = init_collector(state[:args])
        set_collector_timer()
        {:ok, Map.put(state, :internal_state, internal_state)}
      end

      @doc false
      def handle_call(_msg, _from, state) do
        {:noreply, state}
      end

      @doc false
      def handle_info(:collect, state) do
        {:ok, data, internal_state} = collect(state.internal_state)
        transfer(data, state.label, state.transfers)
        set_collector_timer()
        {:noreply, %{state | internal_state: internal_state}}
      end
      def handle_info(_msg, state) do
        {:noreply, state}
      end

      @doc false
      def handle_cast(msg, state) do
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

      @doc false
      def transfer(data, label, transfers) do
        Enum.each(transfers, &GenServer.cast(&1, %{label: label, data: data}))
        :ok
      end

      defp set_collector_timer() do
        Process.send_after(self(), :collect, 5000) # TODO timeout must be configurable
      end

    end
  end

end