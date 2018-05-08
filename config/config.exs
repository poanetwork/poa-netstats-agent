use Mix.Config


# configuration for collectors. The format for each collector is {collector_process_id, module, [target_transfers], label, args}
config :poa_agent, 
       :collectors,
       [
         {:my_collector, POAAgent.Plugins.Collectors.MyCollector, :my_metrics, [host: "localhost", port: 1234]}
       ]

# configuration for transfers. The format for each collector is {collector_process_id, module, args}
config :poa_agent, 
       :transfers,
       [
         {:my_transfer, POAAgent.Plugins.Transfers.MyTransfer, [ws_key: "mykey", other_stuff: "hello"]}
       ]

# configuration for mappings. This relates one collector with a list of transfers which the data will be sent
config :poa_agent,
       :mappings,
       [
         {:my_collector, [:my_transfer]}
       ]