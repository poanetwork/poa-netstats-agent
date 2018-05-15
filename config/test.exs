use Mix.Config

config :poa_agent, POAAgent.Plugins.Transfers.WebSocket.Primus,
    address: "ws://localhost:3000/api",
    identifier: "elixirNodeJSIntegration",
    name: "Elixir-NodeJS-Integration",
    secret: ""
