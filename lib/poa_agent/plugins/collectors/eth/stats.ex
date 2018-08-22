defmodule POAAgent.Plugins.Collectors.Eth.Stats do
  use POAAgent.Plugins.Collector

  @moduledoc """
  This is a Collector's Plugin which makes requests to a Ethereum node in order to know if
  the stats has been changed.

  This Collector needs the url of the node to iteract. That url must be placed in the args field 
  in the config file. For example:

      {:eth_stats, POAAgent.Plugins.Collectors.Eth.Stats, 5000, :eth_stats, [url: "http://localhost:8545"]}

  In this example, the Collector will check with the Ethereum node every 5 seconds if the stats of the
  node has changed. If that is the case it will send it to the Transfers
  encapsulated in a `POAAgent.Entity.Ethereum.Statistics` struct

  """

  @typep internal_state :: %{last_stats: POAAgent.Entity.Ethereum.Statistics.t | nil,
                             tries: non_neg_integer,
                             down: non_neg_integer}

  @doc false
  @spec init_collector(term()) :: {:ok, internal_state()}
  def init_collector(args) do
    :ok = config(args)

    case get_stats(0, 0) do
      {:ok, stats, tries, down} ->
        {:transfer, stats, %{last_stats: stats, tries: tries, down: down}}
      {:error, tries, down} ->
        stats = inactive_stats(tries, down)
        {:transfer, stats, %{last_stats: nil, tries: tries, down: down}}
    end
  end

  @doc false
  @spec collect(internal_state()) :: term()
  def collect(%{last_stats: last_stats, tries: tries, down: down} = state) do
    case get_stats(tries, down) do
      {:ok, ^last_stats, tries, down} ->
        {:notransfer, %{state | tries: tries, down: down}}
      {:ok, stats, tries, down} ->
        {:transfer, stats, %{state | last_stats: stats, tries: tries, down: down}}
      {:error, tries, down} ->
        stats = inactive_stats(tries, down)
        {:transfer, stats, %{last_stats: nil, tries: tries, down: down}}
    end
  end

  @doc false
  @spec metric_type() :: String.t
  def metric_type do
    "ethereum_metrics"
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
  defp get_stats(tries, down) do
    tries = tries + 1

    with {:ok, peers} <- Ethereumex.HttpClient.net_peer_count(),
         {:ok, mining} <- Ethereumex.HttpClient.eth_mining(),
         {:ok, hashrate} <- Ethereumex.HttpClient.eth_hashrate(),
         {:ok, syncing} <- Ethereumex.HttpClient.eth_syncing(),
         {:ok, gas_price} <- Ethereumex.HttpClient.eth_gas_price()
    do
      peers = String.to_integer(POAAgent.Format.Literal.Hex.decimalize(peers))
      hashrate = String.to_integer(POAAgent.Format.Literal.Hex.decimalize(hashrate))
      gas_price = String.to_integer(POAAgent.Format.Literal.Hex.decimalize(gas_price))

      down =
        if peers == 0 do
          down + 1
        else
          down
        end
 
      stats =
        %POAAgent.Entity.Ethereum.Statistics{
          active?: peers > 0,
          mining?: mining,
          hashrate: hashrate,
          peers: peers,
          gas_price: gas_price,
          syncing?: syncing,
          uptime: uptime(tries, down)
        }

      {:ok, stats, tries, down}
    else
      _error -> {:error, tries, down}
    end
  end

  defp inactive_stats(tries, down) do
    %POAAgent.Entity.Ethereum.Statistics{
      active?: false,
      mining?: false,
      hashrate: 0,
      peers: 0,
      uptime: uptime(tries, down)
    }
  end

  defp uptime(tries, down) do
    ((tries - down) / tries) * 100
  end
end
