defmodule POAAgent.Transfers.WebSocketTest do
  use ExUnit.Case
  alias POAAgent.Transfers.WebSocket.Primus
  alias Jason, as: JSON

  @tag :system
  test "integration w/ Node/JS server over Primus/WebSocket" do
    import POAAgent.Ancillary.Entity, only: [
      information: 0,
      block: 0,
      statistics: 0,
      history: 0
    ]

    entities = [
      information(),
      block(),
      statistics(),
      [], ## A history w/ no blocks
      history()
    ]
    context = struct!(Primus.State, Application.get_env(:poa_agent, Primus))
    encode = fn entity ->
      entity
      |> POAAgent.Transfers.WebSocket.Primus.encode(context)
      |> JSON.encode!()
    end

    state = nil
    address = Map.fetch!(context, :address)
    {:ok, client} = Primus.Client.start_link(address, state)

    for entity <- entities do
      assert Primus.Client.send(client, encode.(entity)) == :ok
    end
  end
end
