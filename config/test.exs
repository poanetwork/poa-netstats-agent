use Mix.Config

config :poa_agent, POAAgent.Transfers.WebSocket.Primus,
    address: "ws://localhost:3000/api",
    identifier: "elixirNodeJSIntegration",
    name: "Elixir-NodeJS-Integration",
    secret: ""
