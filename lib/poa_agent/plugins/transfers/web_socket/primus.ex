defmodule POAAgent.Plugins.Transfers.WebSocket.Primus do
  use POAAgent.Plugins.Transfer

  alias POAAgent.Entity

  alias POAAgent.Entity.Host
  alias POAAgent.Entity.Ethereum

  alias POAAgent.Plugins.Transfers.WebSocket.Primus

  alias POAAgent.Entity.Host.Information

  defmodule State do
    @moduledoc false

    defstruct [
      :address,
      :identifier,
      :name,
      :secret,
      :contact
    ]
  end

  def init_transfer(_) do
    context = struct!(Primus.State, Application.get_env(:poa_agent, Primus))
    state = nil
    address = Map.fetch!(context, :address)
    {:ok, client} = Primus.Client.start_link(address, state)

    event = information()
    |> Primus.encode(context)
    |> Jason.encode!()
    :ok = Primus.Client.send(client, event)

    {:ok, %{client: client, context: context}}
  end

  def data_received(label, data, %{client: client, context: context} = state) do
    require Logger
    Logger.info("Received data from the collector referenced by label: #{label}.")

    event = data
    |> Primus.encode(context)
    |> Jason.encode!()
    :ok = Primus.Client.send(client, event)

    {:ok, state}
  end

  def terminate(_) do
    :ok
  end

  def encode(%Host.Information{} = x, %Primus.State{identifier: i, secret: s}) do
    x = Entity.NameConvention.from_elixir_to_node(x)

    %{}
    |> Map.put(:id, i)
    |> Map.put(:secret, s)
    |> Map.put(:info, x)
    |> POAAgent.Format.PrimusEmitter.wrap(event: "hello")
  end

  def encode(%Ethereum.Block{} = x, %Primus.State{identifier: i}) do
    x = Entity.NameConvention.from_elixir_to_node(x)

    %{}
    |> Map.put(:id, i)
    |> Map.put(:block, x)
    |> POAAgent.Format.PrimusEmitter.wrap(event: "block")
  end

  def encode(%Ethereum.Statistics{} = x, %Primus.State{identifier: i}) do
    x = Entity.NameConvention.from_elixir_to_node(x)

    %{}
    |> Map.put(:id, i)
    |> Map.put(:stats, x)
    |> POAAgent.Format.PrimusEmitter.wrap(event: "stats")
  end

  def encode(x, %Primus.State{identifier: i}) do
    %{}
    |> Map.put(:id, i)
    |> Map.put(:history, x)
    |> POAAgent.Format.PrimusEmitter.wrap(event: "history")
  end

  def information() do
    config = Application.get_env(:poa_agent, __MODULE__)

    with {:ok, coinbase} <- Ethereumex.HttpClient.eth_coinbase(),
         {:ok, protocol} <-  Ethereumex.HttpClient.eth_protocol_version(),
         {:ok, node} <- Ethereumex.HttpClient.web3_client_version(),
         {:ok, net} <- Ethereumex.HttpClient.net_version()
    do
      %Information{
        Information.new() |
          name: config[:name],
          contact: config[:contact],
          coinbase: coinbase,
          protocol: String.to_integer(protocol),
          node: node,
          net: net
      }
    else
      _error -> Information.new()
    end
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

    def handle_frame({_type, _msg} = frame, state) do
      require Logger

      Logger.info("got an unexpected frame: #{inspect frame}")
      {:ok, state}
    end
  end
end
