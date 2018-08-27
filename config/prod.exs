use Mix.Config

config :poa_agent,
    config_overlay: "config/config_overlay.json"

config :ethereumex,
    url: "http://localhost:8545"

# configuration for collectors. The format for each collector is {collector_process_id, module, label, args}
config :poa_agent, 
       :collectors,
       [
         {:eth_information, POAAgent.Plugins.Collectors.Eth.Information, 60_000, :eth_information, [url: "http://localhost:8545", name: "Elixir-NodeJS-Integration", contact: "myemail@gmail.com"]},
         {:eth_latest_block, POAAgent.Plugins.Collectors.Eth.LatestBlock, 500, :latest_block, [url: "http://localhost:8545"]},
         {:eth_stats, POAAgent.Plugins.Collectors.Eth.Stats, 5000, :eth_stats, [url: "http://localhost:8545"]},
         {:eth_pending, POAAgent.Plugins.Collectors.Eth.Pending, 500, :eth_pending, [url: "http://localhost:8545"]},
         {:system_collector, POAAgent.Plugins.Collectors.System.Stats, 5_000, :system_metrics, []}
       ]

# configuration for transfers. The format for each collector is {collector_process_id, module, args}
config :poa_agent, 
       :transfers,
       [
         {:rest_transfer, POAAgent.Plugins.Transfers.HTTP.REST, [
             address: "http://localhost:4002",
             identifier: "elixirNodeJSIntegration",

             # Authentication parameters
             user: "rUN7afCO",
             password: "_3IC09xfMtAW4Hr",
             token_url: "https://localhost:4003/session"
           ]
         }
       ]

# configuration for mappings. This relates one collector with a list of transfers which the data will be sent
config :poa_agent,
       :mappings,
       [
         {:eth_latest_block, [:rest_transfer]},
         {:eth_stats, [:rest_transfer]},
         {:eth_pending, [:rest_transfer]},
         {:eth_information, [:rest_transfer]},
         {:system_collector, []}
       ]
