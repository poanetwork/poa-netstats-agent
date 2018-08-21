# Starting Guide

With this guide we are going to go thru an example of how to set up the agent and connect with the `POA Warehouse`.

# Brief introduction

`POAAgent` is built on top of a Collector's Plugin Mechanism. You can add, remove and create your own one. We have developed some collectors but you can create your own ones. Check [how to implement a collector](POAAgent.Plugins.Collector.html).

The `Collectors` send data to `Transfers`. A transfer is an Elixir process which will receive the data. You can implement your own Transfer, check [this](POAAgent.Plugins.Transfer.html). We have developed a transfer in order to send data to the [POA Warehouse](https://github.com/poanetwork/poa-netstats-warehouse).

Every collector can send data to one or many different transfers. The mapping between collectors and Transfers is done in the config file.

In our example we are going to add 4 collectors
- Information Collector: This collector sends Ethereum info to the Transfers periodically.
- Latest Block Collector: This collector "listens" the Ethereum node checking if a new block has been added. Once a new token is detected it will be sent to the mapped Transfers.
- Stats Collector: This collector checks periodically the Ethereum node in order to see if the stats has changed. When changed it will send the data to the transfers.
- Pending Transactions Collector: This collector checks with the Ethereum node if the value of "Pending Transactions" has changed, if that is the case it will send the data to the Transfers.

## Setting up

The collectors we want to use need an Ethereum node to monitor so we will need the host:port. In our example my Ethereum node is running in `http://localhost:8545`

In order to configure the Agent we have to fill a config file. In this case we are going to call it `prod.exs`. We are going to fill it step by step:

We have use the `Mix.Config` module, this is needed in every Elixir Config file.

```
use Mix.Config
```

Next we have to indicate the overlay configuration, you can check how that works [here](POAAgent.html#module-configuration) but in our case the `config_overlay.json` will remain without changes.

```
config :poa_agent,
    config_overlay: "config/config_overlay.json"
```

Now we need the `Ethereumex` configuration. [Ethereumex](https://github.com/exthereum/ethereumex) is the Elixir library we are using to communicate with the Ethereum node. There we have to put the Ethereum url.

```
config :ethereumex,
    url: "http://localhost:8545"
```

We also need the configuration for the Collectors, here we have to indicate the ones we are going to use.

```
config :poa_agent, 
       :collectors,
       [
         {:eth_information, POAAgent.Plugins.Collectors.Eth.Information, 60_000, :eth_information, [url: "http://localhost:8545", name: "Elixir-NodeJS-Integration", contact: "myemail@gmail.com"]},
         {:eth_latest_block, POAAgent.Plugins.Collectors.Eth.LatestBlock, 500, :latest_block, [url: "http://localhost:8545"]},
         {:eth_stats, POAAgent.Plugins.Collectors.Eth.Stats, 5000, :eth_stats, [url: "http://localhost:8545"]},
         {:eth_pending, POAAgent.Plugins.Collectors.Eth.Pending, 500, :eth_pending, [url: "http://localhost:8545"]}
         
       ]
```

You can check in the docs what each field mean in the configuration but it is quite straightforward.

Now we are going to configure the Transfer information. For now we are not going to use transfers (we will check how to use the Warehouse transfer later).

```
config :poa_agent, 
       :transfers,
       [
       ]
```

The last steps is configuring the mapping. Mapping is where we say to which Transfers each Collector is going to send the data. In our case is straightforward since we are not using Transfers

```
config :poa_agent,
       :mappings,
       [
         {:eth_latest_block, []},
         {:eth_stats, []},
         {:eth_pending, []},
         {:eth_information, []}
       ]
```

with this configuration the agent must be able to start running the command

```
MIX_ENV=prod iex -S mix
```

`MIX_ENV=prod` sets a Environment variable used by mix to `prod`. We are using that variable for choosing the config files. That means we are going to use `prod.exs` as a configuration file.

This will start the agent directly in the terminal. If you want to create a release you must read [this](POAAgent.html#module-building-deploying-an-executable)

## Connecting to POA Warehouse

In order to connect with POA Warehouse we have to use a Transfer which is aligned with the POA's protocol. We have developed a Transfer called `REST` which implements the REST version of the POA's protocol. In order to use it we have to declare it in the Config file.

Let's update the `transfers` section in the `prod.exs` file

```
config :poa_agent, 
       :transfers,
       [
         {:rest_transfer, POAAgent.Plugins.Transfers.HTTP.REST, [
             address: "http://localhost:4002",
             identifier: "elixirNodeJSIntegration",

             # Authentication parameters
             user: "",
             password: "",
             token_url: ""
           ]
         }
       ]
```

Well, it seems we need some Auth parameters before starting the Agent. We need a valid user with a valid password and we also need a url in order to request JWT tokens

First we will create a valid user/password. If you want to join POA's network you have to ask them for a new user/password. If you have access to the Warehouse you have to call the _create user_ endpoint.

Let's assume we have access to the Warehouse and it is running in `https://localhost:4003`. We start asking for a user/password with a valid Admin user and Admin Password. The Admin is "admin1" and the password "password12345678". We can find the documentation about the user endpoint [here](https://rawgit.com/poanetwork/poa-netstats-warehouse/master/doc/POABackend.Auth.REST.html#module-user-endpoint).

```
curl -i -X POST -H "Authorization: Basic YWRtaW4xOnBhc3N3b3JkMTIzNDU2Nzg=" -H "Content-Type: application/json" https://localhost:4003/user --insecure

HTTP/1.1 200 OK
server: Cowboy
date: Tue, 21 Aug 2018 00:18:29 GMT
content-length: 53
cache-control: max-age=0, private, must-revalidate

{"user-name":"BK3eiZcT","password":"MPr1n9B-ipvpYbj"}
```

There we have our user name and password. We also know the token url is in `https://localhost:4003/session`. Now we have to update the config file.

```
config :poa_agent, 
       :transfers,
       [
         {:rest_transfer, POAAgent.Plugins.Transfers.HTTP.REST, [
             address: "http://localhost:4002",
             identifier: "elixirNodeJSIntegration",

             # Authentication parameters
             user: "BK3eiZcT",
             password: "MPr1n9B-ipvpYbj",
             token_url: "https://localhost:4003/session"
           ]
         }
       ]
```

We have more configuration to update. Since we have added a Transfer we have to send data to it, so we have to make all the collectors sending data to that `rest_transfer`

```
config :poa_agent,
       :mappings,
       [
         {:eth_latest_block, [:rest_transfer]},
         {:eth_stats, [:rest_transfer]},
         {:eth_pending, [:rest_transfer]},
         {:eth_information, [:rest_transfer]}
       ]
```

Now we can stop the agent and start again.

```
MIX_ENV=prod iex -S mix
```

Now you will see in the Agent's terminal the transfer is requesting a token and sending data to the Warehouse.