defmodule POAAgent.Plugins.Transfers.WebSocket.Primus do
  use POAAgent.Plugins.Transfer

  alias POAAgent.Entity

  alias POAAgent.Entity.Host
  alias POAAgent.Entity.Ethereum

  alias POAAgent.Plugins.Transfers.WebSocket.Primus

  alias POAAgent.Entity.Host.Information
  alias POAAgent.Plugins.Collectors.Eth.LatestBlock

  require Logger

  defmodule State do
    @moduledoc false

    defstruct [
      address: nil,
      identifier: nil,
      name: nil,
      secret: nil,
      contact: nil,
      connected?: false,
      current_backoff: 1,
      client: nil,
      ping_timer_ref: nil,
      hello_timer_ref: nil,
      last_block: nil,
      last_metrics: %{}
    ]
  end

  @ping_frequency 3_000
  @backoff_ceiling 32

  def init_transfer(configuration) do
    false = Process.flag(:trap_exit, true)
    state = struct(Primus.State, configuration)
    set_connection_attempt_timer(0)
    {:ok, state}
  end

  def data_received(label, data, %{connected?: false} = state) when is_list(data) do
    last_metrics = Enum.reduce(data, state.last_metrics, fn(message, metrics) ->
      Map.put(metrics, label, message)
    end)

    {:ok, %{state | last_metrics: last_metrics}}
  end

  def data_received(label, [%Ethereum.Block{} = block], %{client: client} = state) do
    require Logger
    Logger.info("Received data from the collector referenced by label: #{label}.")

    # we have to check if is the first block sent, if that is the case we must send the
    # history too. That case makes sense when the agent starts and the Ethereum node is down

    case state.last_metrics[label] do
      nil -> send_block_and_history(block, client, state)
      _ -> send_metric(block, client, state)
    end

    {:ok, %{state | last_metrics: Map.put(state.last_metrics, label, block)}}
  end

  def data_received(label, data, %{client: client} = state) when is_list(data) do
    require Logger
    Logger.info("Received data from the collector referenced by label: #{label}.")

    last_metrics = Enum.reduce(data, state.last_metrics, fn(message, metrics) ->
      :ok = send_metric(message, client, state)

      Map.put(metrics, label, message)
    end)

    {:ok, %{state | last_metrics: last_metrics}}
  end

  def data_received(label, data, state) do
    data_received(label, [data], state)
  end

  def handle_message(:attempt_to_connect, state) do
    address = Map.fetch!(state, :address)
    case Primus.Client.start_link(address, state) do
      {:ok, client} ->
        hello_timer_ref = set_hello_timer(seconds: 0)
        ping_timer_ref = set_ping_timer()

        :ok = send_last_metrics(client, state)

        {:ok, %{state | connected?: true, client: client, current_backoff: 1, ping_timer_ref: ping_timer_ref, hello_timer_ref: hello_timer_ref}}
      {:error, reason} ->
        Logger.warn("Connection refused because: #{inspect reason}")
        {:ok, %{state | connected?: false, client: nil}}
    end
  end

  def handle_message(:ping, %{client: client} = state) do
    event = %{}
    |> Map.put(:id, state.identifier)
    |> Map.put(:clientTime, POAAgent.Utils.system_time())
    |> POAAgent.Format.PrimusEmitter.wrap(event: "node-ping")
    |> Jason.encode!()

    :ok = Primus.Client.send(client, event)

    ping_timer_ref = set_ping_timer()

    {:ok, %{state | ping_timer_ref: ping_timer_ref}}
  end

  def handle_message(:sample_and_send_hello, state) do
    set_up_and_send_hello(state.client, state)
    hello_timer_ref = set_hello_timer(seconds: 60)
    {:ok, %{state | hello_timer_ref: hello_timer_ref}}
  end

  def handle_message({:EXIT, _pid, _reason}, state) do
    case state.ping_timer_ref do
      nil -> :continue
      _ -> Process.cancel_timer(state.ping_timer_ref)
    end
    new_backoff = backoff(state.current_backoff, @backoff_ceiling)
    set_connection_attempt_timer(new_backoff)
    {:ok, %{state | current_backoff: new_backoff + 1, connected?: false, client: nil}}
  end

  def terminate(_) do
    :ok
  end

  defp encode(%Host.Information{} = x, %Primus.State{identifier: i, secret: s}) do
    x = Entity.NameConvention.from_elixir_to_node(x)

    %{}
    |> Map.put(:id, i)
    |> Map.put(:secret, s)
    |> Map.put(:info, x)
    |> POAAgent.Format.PrimusEmitter.wrap(event: "hello")
  end

  defp encode(%Ethereum.Block{} = x, %Primus.State{identifier: i}) do
    x = Entity.NameConvention.from_elixir_to_node(x)

    %{}
    |> Map.put(:id, i)
    |> Map.put(:block, x)
    |> POAAgent.Format.PrimusEmitter.wrap(event: "block")
  end

  defp encode(%Ethereum.Statistics{} = x, %Primus.State{identifier: i}) do
    x = Entity.NameConvention.from_elixir_to_node(x)

    %{}
    |> Map.put(:id, i)
    |> Map.put(:stats, x)
    |> POAAgent.Format.PrimusEmitter.wrap(event: "stats")
  end

  defp encode(%POAAgent.Entity.Ethereum.History{} = x, %Primus.State{identifier: i}) do
    history = for i <- x.history do
      Entity.NameConvention.from_elixir_to_node(i)
    end

    %{}
    |> Map.put(:id, i)
    |> Map.put(:history, history)
    |> POAAgent.Format.PrimusEmitter.wrap(event: "history")
  end

  defp encode(%POAAgent.Entity.Ethereum.Pending{} = x, %Primus.State{identifier: i}) do
    x = Entity.NameConvention.from_elixir_to_node(x)

    %{}
    |> Map.put(:id, i)
    |> Map.put(:stats, x)
    |> POAAgent.Format.PrimusEmitter.wrap(event: "pending")
  end

  defp information(config) do
    with {:ok, coinbase} <- Ethereumex.HttpClient.eth_coinbase(),
         {:ok, protocol} <-  Ethereumex.HttpClient.eth_protocol_version(),
         {:ok, node} <- Ethereumex.HttpClient.web3_client_version(),
         {:ok, net} <- Ethereumex.HttpClient.net_version()
    do
      %Information{
        Information.new() |
          name: config.name,
          contact: config.contact,
          coinbase: coinbase,
          protocol: String.to_integer(protocol),
          node: node,
          net: net
      }
    else
      _error ->
        %Information{
          Information.new() |
            name: config.name,
            contact: config.contact
        }
    end
  end

  defp set_ping_timer() do
    Process.send_after(self(), :ping, @ping_frequency)
  end

  defp set_connection_attempt_timer(backoff_time) do
    Process.send_after(self(), :attempt_to_connect, backoff_time * 1000)
  end

  defp set_hello_timer(seconds: s) do
    Process.send_after(self(), :sample_and_send_hello, s * 1000)
  end

  defp backoff(backoff, ceiling) do
    case (:math.pow(2, backoff) - 1) do
      result when result > ceiling ->
        ceiling
      next_backoff ->
        round(next_backoff)
    end
  end

  defp set_up_and_send_hello(client, state) do
    event = 
    state
    |> information()
    |> encode(state)
    |> Jason.encode!()
    :ok = Primus.Client.send(client, event)
  end

  defp send_last_metrics(client, state) do
    state.last_metrics
    |> Enum.each(fn
      {_label, %Ethereum.Block{} = block} ->
        :ok = send_block_and_history(block, client, state)
      {_label, message} ->
        :ok = send_metric(message, client, state)
      end)
  end

  defp send_block_and_history(block, client, state) do
    range = LatestBlock.history_range(block, 0)
    history = LatestBlock.history(range)

    :ok = send_metric(block, client, state)
    :ok = send_metric(history, client, state)

    :ok
  end

  defp send_metric(metric, client, state) do
    event =
      metric
      |> encode(state)
      |> Jason.encode!()

      Primus.Client.send(client, event)
  end

  defmodule Client do
    @moduledoc false

    use WebSockex

    def send(handle, message) do
      WebSockex.send_frame(handle, {:text, message})
    end

    def start_link(address, state) do
      WebSockex.start_link(address, __MODULE__, state)
    end

    def handle_frame({:text, event}, state) do
      event = Jason.decode!(event)

      handle_primus_event(event["emit"], state)
    end
    def handle_frame({_type, _msg} = frame, state) do
      require Logger

      Logger.info("got an unexpected frame: #{inspect frame}")
      {:ok, state}
    end

    defp handle_primus_event(["node-pong", data], state) do
      now = POAAgent.Utils.system_time()
      latency = Float.ceil((now - data["clientTime"]) / 2)
      event = %{}
      |> Map.put(:id, state.identifier)
      |> Map.put(:latency, latency)
      |> POAAgent.Format.PrimusEmitter.wrap(event: "latency")
      |> Jason.encode!()

      {:reply, {:text, event}, state}
    end
    defp handle_primus_event(["history", %{"max" => max, "min" => min}], state) do

      h = LatestBlock.history(min..max)

      history = for i <- h.history do
        Entity.NameConvention.from_elixir_to_node(i)
      end

      event = %{}
      |> Map.put(:id, state.identifier)
      |> Map.put(:history, history)
      |> POAAgent.Format.PrimusEmitter.wrap(event: "history")
      |> Jason.encode!()

      {:reply, {:text, event}, state}
    end

    defp handle_primus_event(data, state) do
      require Logger

      Logger.info("got an unexpected message: #{inspect data}")
      {:ok, state}
    end
  end
end
