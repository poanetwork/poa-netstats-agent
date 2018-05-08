defmodule POAAgent.Plugins.Transfer do

  @callback init_transfer(args :: term()) ::
      {:ok, any()}

  @callback data_received(label :: atom(), data :: any(), state :: any()) :: {:ok, any()}

  @callback terminate(state :: term()) :: term()

  defmacro __using__(_opt) do
    quote do
      @behaviour POAAgent.Plugins.Transfer

      @doc false
      def start_link(%{name: name} = state) do
        GenServer.start_link(__MODULE__, state, name: name)
      end

      @doc false
      def init(state) do
        {:ok, internal_state} = init_transfer(state[:args])
        {:ok, Map.put(state, :internal_state, internal_state)}
      end

      @doc false
      def handle_call(_msg, _from, state) do
        {:noreply, state}
      end

      @doc false
      def handle_info(_msg, state) do
        {:noreply, state}
      end

      @doc false
      def handle_cast(%{label: label, data: data}, state) do
        {:ok, internal_state} = data_received(label, data, state.internal_state)
        {:noreply, %{state | internal_state: internal_state}}
      end
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

    end
  end

end