defmodule POAAgent.ConfigurationTest do
  use ExUnit.Case

  test "Transfers overlay all fields" do
    original_transfers = Application.fetch_env!(:poa_agent, :transfers)

    transfers = [
       {:rest_transfer, POAAgent.Plugins.Transfers.HTTP.REST, [
           address: "http://localhost:4002",
           identifier: "elixirNodeJSIntegration",
           secret: "mysecret"
         ]
       }
     ]

    :ok = Application.put_env(:poa_agent, :transfers, transfers)

    assert transfers == Application.fetch_env!(:poa_agent, :transfers)

    # those values are in the test/poa_agent/config_overlay.json file
    new_address = "http://localhost:4003"
    new_identifier = "NewIdentifier"
    new_secret = "newsecret"

    [{:rest_transfer, POAAgent.Plugins.Transfers.HTTP.REST, new_args}] = POAAgent.Configuration.Transfers.config()

    assert new_address == new_args[:address]
    assert new_identifier == new_args[:identifier]
    assert new_secret == new_args[:secret]

    # putting back the original value
    :ok = Application.put_env(:poa_agent, :transfers, original_transfers)

    assert original_transfers == Application.fetch_env!(:poa_agent, :transfers)
  end

  test "Collectors overlay all fields" do
    original_collectors = Application.fetch_env!(:poa_agent, :collectors)

    collectors = [
       {:eth_information, POAAgent.Plugins.Collectors.Eth.Information, 60_000, :eth_information, [
          url: "http://localhost:8545",
          name: "Elixir-NodeJS-Integration",
          contact: "myemail@gmail.com"
          ]
       }
     ]

    :ok = Application.put_env(:poa_agent, :collectors, collectors)

    assert collectors == Application.fetch_env!(:poa_agent, :collectors)

    # # those values are in the test/poa_agent/config_overlay.json file
    new_url = "http://localhost:8546"
    new_name = "NewNodeName"
    new_contact = "mynewemail@gmail.com"

    [{:eth_information, POAAgent.Plugins.Collectors.Eth.Information, 60_000, :eth_information, new_args}] = POAAgent.Configuration.Collectors.config()

    assert new_url == new_args[:url]
    assert new_name == new_args[:name]
    assert new_contact == new_args[:contact]

    # putting back the original value
    :ok = Application.put_env(:poa_agent, :collectors, original_collectors)

    assert original_collectors == Application.fetch_env!(:poa_agent, :collectors)
  end
end
