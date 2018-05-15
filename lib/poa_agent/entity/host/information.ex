defmodule POAAgent.Entity.Host.Information do
  @moduledoc false
  alias POAAgent.Format.Literal

  @type t :: %__MODULE__{
    name: String.t(),
    contact: URI.t(),
    coinbase: Literal.Hex.t(),
    node: String.t(),
    net: Literal.Decimal.t(),
    protocol: pos_integer,
    api: Version.t(),
    port: Literal.Decimal.t(), ## :inet.port_number()
    os: String.t(),
    os_v: Version.t(),
    client: Version.t(),
    can_update_history?: boolean
  }

  defstruct [
    :name,
    :contact,
    :coinbase,
    :node,
    :net,
    :protocol,
    :api,
    :port,
    :os,
    :os_v,
    :client,
    :can_update_history?
  ]

  def new do
    %__MODULE__{
      name: nil,
      contact: nil,
      coinbase: nil,
      node: nil,
      net: nil,
      protocol: nil,
      api: "", # this field belongs to JS version, doesn't make sense here
      port: "", # TODO
      os: os(),
      os_v: os_version(),
      client: client(),
      can_update_history?: true
    }
  end

  defp os do
    {_, os} = :os.type()
    Atom.to_string(os)
  end

  defp os_version do
    case :os.version() do
      {_, _, _} = version ->
        version
        |> Tuple.to_list
        |> Enum.map(&(Integer.to_string(&1)))
        |> Enum.join(".")
      version -> version
    end
  end

  defp client do
    {:ok, version} = :application.get_key(:poa_agent, :vsn)
    List.to_string(version)
  end

  defimpl POAAgent.Entity.NameConvention do
    def from_elixir_to_node(x) do
      mapping = [
        can_update_history?: :canUpdateHistory
      ]
      x = Enum.reduce(mapping, x, &POAAgent.Entity.Name.change/2)
      Map.from_struct(x)
    end
  end
end