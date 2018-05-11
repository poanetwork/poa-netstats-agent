defmodule POAAgent.Plugins.Transfer do

  @moduledoc """
  Defines a Transfer Plugin.

  A Transfer plugin receives data from Collectors. It uses the Collector's `label` in order to
  differenciate from multiple Collectors.

  `POAAgent` app reads the Transfers configuration from the `config.exs` file when bootstrap and will create a
  process per each one of them. That configuration is referenced by :transfers key.

      config :poa_agent,
         :transfers,
         [
           {name, module, args}
         ]

  for example

      config :poa_agent,
         :transfers,
         [
           {:my_transfer, POAAgent.Plugins.Transfers.MyTransfer, [ws_key: "mykey", other_stuff: "hello"]}
         ]

  `name`, `module` and `args` must be defined in the configuration file.

  - `name`: Name for the new created process. Must be unique
  - `module`: Module which implements the Transfer behaviour
  - `args`: Initial args which will be passed to the `init_transfer/1` function

  In order to implement your Transfer Plugin you must implement 3 functions.

  - `init_transfer/1`: Called only once when the process starts
  - `data_received/2`: This function is called every time a Collector sends metrics to the Transfer
  - `terminate/1`: Called just before stopping the process

  This is a simple example of custom Transfer Plugin

      defmodule POAAgent.Plugins.Transfers.MyTransfer do
        use POAAgent.Plugins.Transfer

        def init_transfer(args) do
          {:ok, :no_state}
        end

        def data_received(label, data, state) do
          IO.puts "Received data from the collector referenced by label"
          {:ok, :no_state}
        end

        def terminate(_state) do
          :ok
        end

      end

  """

  @doc """
    A callback executed when the Transfer Plugin starts.
    The argument is retrieved from the configuration file when the Transfer is defined
    It must return `{:ok, state}`, that `state` will be keept as in `GenServer` and can be
    retrieved in the `data_received/2` function.
  """
  @callback init_transfer(args :: term()) ::
      {:ok, any()}

  @doc """
    In this callback is called when a Collector sends data to this Transfer.

    The data received is in `{label, data}` format where `label` identifies the Collector and the
    data is the real data received.

    It must return `{:ok, state}`.
  """
  @callback data_received(label :: atom(), data :: any(), state :: any()) :: {:ok, any()}

  @doc """
    This callback is called just before the Process goes down. This is a good place for closing connections.
  """
  @callback terminate(state :: term()) :: term()

  @doc false
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