use Mix.Config

config :poa_agent, POAAgent.Plugins.Transfers.WebSocket.Primus,
    address: "ws://localhost:3000/api",
    identifier: "elixirNodeJSIntegration",
    name: "Elixir-NodeJS-Integration",
    secret: "",
    contact: "mymail@mail.com"

config :ethereumex,
    url: "http://localhost:8545"