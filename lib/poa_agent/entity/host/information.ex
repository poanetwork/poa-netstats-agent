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
end
