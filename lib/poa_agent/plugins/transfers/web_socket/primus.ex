defmodule POAAgent.Transfers.WebSocket.Primus do
  alias POAAgent.Entity

  alias POAAgent.Entity.Host
  alias POAAgent.Entity.Ethereum

  alias POAAgent.Transfers.WebSocket.Primus

  defmodule State do
    @moduledoc false

    defstruct [
      :address,
      :identifier,
      :name,
      :secret
    ]
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
