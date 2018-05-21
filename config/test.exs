use Mix.Config

config :ethereumex,
    url: "http://localhost:8545"

# configuration for collectors. The format for each collector is {collector_process_id, module, label, args}
config :poa_agent, 
       :collectors,
       [
         # {:eth_latest_block, POAAgent.Plugins.Collectors.Eth.LatestBlock, 500, :latest_block, [url: "http://localhost:8545"]},
         # {:eth_stats, POAAgent.Plugins.Collectors.Eth.Stats, 5000, :eth_stats, [url: "http://localhost:8545"]},
         # {:eth_pending, POAAgent.Plugins.Collectors.Eth.Pending, 500, :eth_pending, [url: "http://localhost:8545"]}
       ]

# configuration for transfers. The format for each collector is {collector_process_id, module, args}
config :poa_agent, 
       :transfers,
       [
         # {:node_integration, POAAgent.Plugins.Transfers.WebSocket.Primus, [
         #     address: "ws://localhost:3000/api",
         #     identifier: "elixirNodeJSIntegration",
         #     name: "Elixir-NodeJS-Integration",
         #     secret: "Fr00b5",
         #     contact: "mymail@mail.com"
         #   ]
         # }
       ]

# configuration for mappings. This relates one collector with a list of transfers which the data will be sent
config :poa_agent,
       :mappings,
       [
         # {:eth_latest_block, [:node_integration]},
         # {:eth_stats, [:node_integration]},
         # {:eth_pending, [:node_integration]}
       ]
