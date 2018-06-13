defmodule POAAgent.Plugins.Collectors.Eth.Information do
  use POAAgent.Plugins.Collector

  @moduledoc """
  This is a Collector's Plugin which sends peridodically the Ethereum information to the transfer.

  This Collector needs the url of the ethereum node to iteract, the contact email and the node name. That url must be placed in the args field 
  in the config file. For example:

      {:eth_information, POAAgent.Plugins.Collectors.Eth.Information, 60_000, :eth_information, [url: "http://localhost:8545", name: "nodename", contact: "myemail@gmail.com"]}

  In this example, the Collector will send the information to the transfer every minute

  """

  alias POAAgent.Entity.Host.Information

  @typep internal_state :: %{
    information: Information.t,
    args: Keyword.t
  }

  @doc false
  @spec init_collector(term()) :: {:ok, internal_state()}
  def init_collector(args) do
    :ok = config(args)

    information = information(args)

    {:transfer, information, %{information: information, args: args}}
  end

  @doc false
  @spec collect(internal_state()) :: term()
  def collect(%{information: information, args: args} = state) do
    case information(args) do
      ^information ->
        {:notransfer, state}
      information ->
        {:transfer, information, %{state | information: information}}
    end
  end

  @doc false
  @spec terminate(internal_state()) :: :ok
  def terminate(_state) do
    :ok
  end

  @doc false
  defp information(args) do
    {:name, name} = List.keyfind(args, :name, 0)
    {:contact, contact} = List.keyfind(args, :contact, 0)

    with {:ok, coinbase} <- Ethereumex.HttpClient.eth_coinbase(),
         {:ok, protocol} <-  Ethereumex.HttpClient.eth_protocol_version(),
         {:ok, node} <- Ethereumex.HttpClient.web3_client_version(),
         {:ok, net} <- Ethereumex.HttpClient.net_version()
    do
      %Information{
        Information.new() |
          name: name,
          contact: contact,
          coinbase: coinbase,
          protocol: String.to_integer(protocol),
          node: node,
          net: net
      }
    else
      _error ->
        %Information{
          Information.new() |
            name: name,
            contact: contact
        }
    end
  end

  @doc false
  defp config(args) do
    {:url, url} = List.keyfind(args, :url, 0)
    Application.put_env(:ethereumex, :url, url)
    :ok
  end

end
