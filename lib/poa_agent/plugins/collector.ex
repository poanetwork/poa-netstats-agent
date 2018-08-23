defmodule POAAgent.Plugins.Collector do

  @moduledoc """
  Defines a Collector Plugin.

  A Collector plugin will run in an independent process and will run the `collect/1`
  function in a given `frequency`.

  `POAAgent` app reads the Collectors configuration from the `config.exs` file when bootstrap and will create a
  process per each one of them. That configuration is referenced by :collectors key.

      config :poa_agent,
         :collectors,
         [
           {name, module, frequency, label, args}
         ]

  for example

      config :poa_agent,
         :collectors,
         [
           {:my_collector, POAAgent.Plugins.Collectors.MyCollector, 5000, :my_metrics, [host: "localhost", port: 1234]}
         ]

  `name`, `module`, `frequency`, `label` and `args` must be defined in the configuration file.

  - `name`: Name for the new created process. Must be unique
  - `module`: Module which implements the Collector behaviour
  - `frequency`: time in milliseconds after which the function `collect/1` will be called
  - `label`: The data collected will be prefixed with this label. ie `{:eth_metrics, "data"}`
  - `args`: Initial args which will be passed to the `init_collector/1` function

  In order to work properly we have to define in the configuration file also the mapping between the Collector
  and the Transfers related with it. A `Transfer` is a Plugin process which transfers the data to outside the agent node
  (external Database, Dashboard server...).

      config :poa_agent,
           :mappings,
           [
             {collector_name, [transfer_name1, transfer_name2]}
           ]

  for example

      config :poa_agent,
           :mappings,
           [
             {:my_collector, [:my_transfer]}
           ]

  ## Implementing A Collector Plugin

  In order to implement your Collector Plugin you must implement 4 functions.

  - `init_collector/1`: Called only once when the process starts
  - `collect/1`: This function is called periodically after `frequency` milliseconds. It is responsible
  of retrieving the metrics
  - `metric_type/0`: This function must return the metric type in `string` format (i.e "ethereum_metric")
  - `terminate/1`: Called just before stopping the process

  This is a simple example of custom Collector Plugin

      defmodule POAAgent.Plugins.Collectors.MyCollector do
        use POAAgent.Plugins.Collector

        def init_collector(args) do
          {:ok, :no_state}
        end

        def collect(:no_state) do
          IO.puts "I am collecting data!"
          {:transfer, "data retrieved", :no_state}
        end

        def metric_type do
          "my_metrics_type"
        end

        def terminate(_state) do
          :ok
        end

      end

  """

  @doc """
    A callback executed when the Collector Plugin starts.
    The argument is retrieved from the configuration file when the Collector is defined
    It can return `{:ok, state}`, that `state` will be keept as in `GenServer` and can be
    retrieved in the `collect/1` function.
    There are some cases where we want to send data to the transfer after initialize the
    Collector, if that is the case you must return `{:transfer, data, state}` where the data is the
    metrics we want to send to the transfer
  """
  @callback init_collector(args :: term()) :: {:ok, state :: any()}
                                            | {:transfer, data :: any(), state :: any()}

  @doc """
    In this callback is where the metrics collection logic must be placed.
    It must return `{:transfer, data, state}` where `data` is the retrieved metrics or
    `{:notransfer, state}` when for some reason we don't want to send data to the transfer int
    that moment
  """
  @callback collect(state :: any()) :: {:transfer, data :: any(), state :: any()}
                                     | {:notransfer, state :: any()}

  @doc """
  This callback must return the metric type in `string` format. For example, if your collector is gathering metrics about
  Ethereum you can use "ethereum_metric" here.
  """
  @callback metric_type() :: String.t()

  @doc """
    This callback is called just before the Process goes down. This is a good place for closing connections.
  """
  @callback terminate(state :: term()) :: term()

  @doc false
  defmacro __using__(_opt) do
    quote do
      @behaviour POAAgent.Plugins.Collector

      @doc false
      def start_link(%{name: name} = state) do
        GenServer.start_link(__MODULE__, state, name: name)
      end

      @doc false
      def init(state) do
        internal_state =
          case init_collector(state[:args]) do
            {:ok, internal_state} ->
              internal_state
            {:transfer, _, _} = transfer ->
              transfer |> transfer(state.label, state.transfers)
          end

        set_collector_timer(state.frequency)
        {:ok, Map.put(state, :internal_state, internal_state)}
      end

      @doc false
      def handle_call(_msg, _from, state) do
        {:noreply, state}
      end

      @doc false
      def handle_info(:collect, state) do
        internal_state =
          state.internal_state
          |> collect()
          |> transfer(state.label, state.transfers)

        set_collector_timer(state.frequency)
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
      defp transfer({:transfer, data, internal_state}, label, transfers) do
        Enum.each(transfers, &GenServer.cast(&1, %{label: label, metric_type: metric_type(), data: data}))
        internal_state
      end
      defp transfer({:notransfer, internal_state}, _label, _transfers) do
        internal_state
      end

      @doc false
      defp set_collector_timer(frequency) do
        Process.send_after(self(), :collect, frequency)
      end

    end
  end

end
