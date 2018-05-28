defmodule POAAgent.ConfigurationTest do
  use ExUnit.Case

  test "transfer configuration overlay and default merge" do
    default = [
      {:node_integration, POAAgent.Plugins.Transfers.WebSocket.Primus, [
          address: "ws://localhost:3000/api",
          identifier: "elixirNodeJSIntegration",
          name: "Elixir-NodeJS-Integration",
          secret: "",
          contact: "mymail@mail.com"
        ]
      }
    ]
    overlay = %{"POAAgent" =>
                 %{"transfers" =>
                    [
                      %{"address" => "ws://localhost:3000/api",
                        "contact" => "a@b.c",
                        "id" => "node_integration",
                        "identifier" => "elixirNodeJSIntegration",
                        "name" => "Elixir-NodeJS-Integration",
                        "secret" => "Fr00b5"
                       }
                    ]
                  }
               }

    assert POAAgent.Configuration.transfers(overlay, default) == [
      {:node_integration, POAAgent.Plugins.Transfers.WebSocket.Primus,
       [address: "ws://localhost:3000/api",
        contact: "a@b.c",
        identifier: "elixirNodeJSIntegration",
        name: "Elixir-NodeJS-Integration",
        secret: "Fr00b5"
       ]
      }
    ]
    assert POAAgent.Configuration.transfers(overlay, []) == []
  end
end
