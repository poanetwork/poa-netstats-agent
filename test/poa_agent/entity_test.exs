defmodule POAAgent.EntityTest do
  use ExUnit.Case

  test "key transformation is Node/JS friendly" do
    alias POAAgent.Entity.Host
    alias POAAgent.Entity.Ethereum

    good? = fn x ->
      not String.contains?(x, ["_", "?"])
    end
    exception = "os_v"

    x = [Host.Information, Ethereum.Block, Ethereum.Statistics]
    |> Enum.map(&Kernel.struct/1)
    |> Enum.map(&POAAgent.Entity.NameConvention.from_elixir_to_node/1)
    |> Enum.map(&Map.keys/1)
    |> List.flatten()
    |> Enum.map(&Atom.to_string/1)
    |> List.delete(exception)

    assert Enum.all?(x, good?)
  end
end
