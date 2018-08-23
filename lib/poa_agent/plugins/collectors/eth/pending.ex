defmodule POAAgent.Plugins.Collectors.Eth.Pending do
  use POAAgent.Plugins.Collector

  @moduledoc """
  This is a Collector's Plugin which makes requests to a Ethereum node in order to know if
  the "pending" has been changed.

  This Collector needs the url of the node to iteract. That url must be placed in the args field 
  in the config file. For example:

      {:eth_pending, POAAgent.Plugins.Collectors.Eth.Pending, 500, :eth_pending, [url: "http://localhost:8545"]}

  In this example, the Collector will check with the Ethereum node every 500 miliseconds if the pending of the
  node has changed. If that is the case it will send it to the Transfers
  encapsulated in a `POAAgent.Entity.Ethereum.Pending` struct

  """

  @typep internal_state :: %{last_pending: non_neg_integer}

  @doc false
  @spec init_collector(term()) :: {:ok, internal_state()}
  def init_collector(args) do
    :ok = config(args)

    {:ok, %{last_pending: 0}}
  end

  @doc false
  @spec collect(internal_state()) :: term()
  def collect(%{last_pending: last_pending} = state) do
    case pending() do
      ^last_pending ->
        {:notransfer, state}
      pending ->
        {:transfer, format_pending(pending), %{state | last_pending: pending}}
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
  defp pending() do
    case Ethereumex.HttpClient.eth_get_block_transaction_count_by_number("pending") do
      {:ok, pending} -> String.to_integer(POAAgent.Format.Literal.Hex.decimalize(pending))
      _ -> 0
    end
  end

  @doc false
  defp format_pending(pending) do
    %POAAgent.Entity.Ethereum.Pending{
      pending: pending
    }
  end
end
