defmodule POAAgent.Plugins.Collectors.Eth.LatestBlock do
  use POAAgent.Plugins.Collector

  alias POAAgent.Entity.Ethereum.Block

  @moduledoc """
  This is a Collector's Plugin which makes requests to a Ethereum node in order to know if
  a new block has been added.

  It also sends the history when the plugin starts.

  This Collector needs the url of the node to iteract. That url must be placed in the args field 
  in the config file. For example:

      {:eth_latest_block, POAAgent.Plugins.Collectors.Eth.LatestBlock, 500, :latest_block, [url: "http://localhost:8545"]}

  In this example, the Collector will check with the Ethereum node every 500 miliseconds if a new block 
  has been added to the blockchain. If that is the case it will retrieve it and send it to the Transfers
  encapsulated in a `POAAgent.Entity.Ethereum.Block` struct

  """

  @typep internal_state :: %{last_block: String.t}

  @doc false
  @spec init_collector(term()) :: {:ok, internal_state()}
  def init_collector(args) do
    :ok = config(args)

    with block_number <- get_latest_block(),
         {:ok, block} <- Ethereumex.HttpClient.eth_get_block_by_number(block_number, :false)
    do
      block = Block.format_block(block)
      range = history_range(block, 0)
      history = history(range)

      {:transfer, [block, history], %{last_block: block_number}}
    else
      _error -> {:ok, %{last_block: get_latest_block()}}
    end
  end

  @doc false
  @spec collect(internal_state()) :: term()
  def collect(%{last_block: latest_block} = state) do
    case get_latest_block() do
      nil ->
        {:notransfer, state}
      ^latest_block ->
        {:notransfer, state}
      block_number ->
        {:ok, block} = Ethereumex.HttpClient.eth_get_block_by_number(block_number, :false)
        {:transfer, Block.format_block(block), %{state | last_block: block_number}}
    end
  end

  @doc false
  @spec terminate(internal_state()) :: :ok
  def terminate(_state) do
    :ok
  end

  @doc false
  def history_range(block, last_block) do
    max_blocks_history = 40

    from = Enum.max([block.number - max_blocks_history, last_block + 1])
    to = Enum.max([block.number, 0])

    from..to
  end

  @doc false
  def history(range) do
    history =
      try do
        for i <- range do
          block_number = "0x" <> Integer.to_string(i, 16)
          {:ok, block} = Ethereumex.HttpClient.eth_get_block_by_number(block_number, :false)
          Block.format_block(block)
        end
      catch
        _, _ -> []
      end

    %POAAgent.Entity.Ethereum.History{
      history: Enum.reverse(history)
    }
  end

  @doc false
  defp config([url: url]) do
    Application.put_env(:ethereumex, :url, url)
    :ok
  end

  @doc false
  defp get_latest_block() do
    case Ethereumex.HttpClient.eth_block_number do
      {:ok, latest_block} -> latest_block
      _ -> nil
    end
  end

end
