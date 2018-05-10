defmodule POAAgent.Plugins.Collectors.Eth.LatestBlock do
  use POAAgent.Plugins.Collector

  @moduledoc """
  This is a Collector's Plugin which makes requests to a Ethereum node in order to know if
  a new block has been added.

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

    {:ok, %{last_block: get_latest_block()}}
  end

  @doc false
  @spec collect(internal_state()) :: term()
  def collect(%{last_block: latest_block} = state) do
    case get_latest_block() do
      nil ->
        {:notransfer, state}
      ^latest_block ->
        {:notransfer, state}
      latest_block ->
        {:ok, block} = Ethereumex.HttpClient.eth_get_block_by_number(latest_block, :false)
        {:transfer, format_block(block), %{state | last_block: latest_block}}
    end
  end

  @doc false
  @spec terminate(internal_state()) :: :ok
  def terminate(_state) do
    :ok
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

  @doc false
  defp format_block(block) do
    difficulty = POAAgent.Format.Literal.Hex.decimalize(block["difficulty"])
    gas_limit = String.to_integer(POAAgent.Format.Literal.Hex.decimalize(block["gasLimit"]))
    gas_used = String.to_integer(POAAgent.Format.Literal.Hex.decimalize(block["gasUsed"]))
    number = String.to_integer(POAAgent.Format.Literal.Hex.decimalize(block["number"]))
    size = String.to_integer(POAAgent.Format.Literal.Hex.decimalize(block["size"]))
    timestamp = String.to_integer(POAAgent.Format.Literal.Hex.decimalize(block["timestamp"]))
    total_difficulty = POAAgent.Format.Literal.Hex.decimalize(block["totalDifficulty"])

    %POAAgent.Entity.Ethereum.Block{
      author: block["author"],
      difficulty: difficulty,
      extra_data: block["extraData"],
      gas_limit: gas_limit,
      gas_used: gas_used,
      hash: block["hash"],
      miner: block["miner"],
      number: number,
      parent_hash: block["parentHash"],
      receipts_root: block["receiptsRoot"],
      seal_fields: block["sealFields"],
      sha3_uncles: block["sha3Uncles"],
      signature: block["signature"],
      size: size,
      state_root: block["stateRoot"],
      step: block["step"],
      timestamp: timestamp,
      total_difficulty: total_difficulty,
      transactions: block["transactions"],
      transactions_root: block["transactionsRoot"],
      uncles: block["uncles"]
    }
  end

end