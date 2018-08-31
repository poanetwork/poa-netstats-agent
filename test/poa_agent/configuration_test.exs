defmodule POAAgent.ConfigurationTest do
  use ExUnit.Case

  test "Transfers overlay all fields" do
    original_transfers = Application.fetch_env!(:poa_agent, :transfers)

    transfers = [
       {:rest_transfer, POAAgent.Plugins.Transfers.HTTP.REST, [
             address: "http://localhost:4002",
             identifier: "elixirNodeJSIntegration",
             user: "AhvK0DSj",
             password: "EkiuUkyOD6KLas8",
             token_url: "https://localhost:4003/session"
           ]
         }
     ]

    :ok = Application.put_env(:poa_agent, :transfers, transfers)

    assert transfers == Application.fetch_env!(:poa_agent, :transfers)

    # those values are in the test/poa_agent/config_overlay.json file
    new_address = "http://localhost:4003"
    new_identifier = "NewIdentifier"
    new_user = "user1"
    new_password = "password1"

    [{:rest_transfer, POAAgent.Plugins.Transfers.HTTP.REST, new_args}] = POAAgent.Configuration.Transfers.config()

    assert new_address == new_args[:address]
    assert new_identifier == new_args[:identifier]
    assert new_user == new_args[:user]
    assert new_password == new_args[:password]
    assert "https://localhost:4003/session" == new_args[:token_url]

    # putting back the original value
    :ok = Application.put_env(:poa_agent, :transfers, original_transfers)

    assert original_transfers == Application.fetch_env!(:poa_agent, :transfers)
  end

  test "Transfers overlay doesn't exist in default" do
    original_transfers = Application.fetch_env!(:poa_agent, :transfers)

    transfers = [
       {:rest_transfer2, POAAgent.Plugins.Transfers.HTTP.REST, [
             address: "http://localhost:4002",
             identifier: "elixirNodeJSIntegration",
             user: "AhvK0DSj",
             password: "EkiuUkyOD6KLas8",
             token_url: "https://localhost:4003/session"
           ]
         }
     ]

    :ok = Application.put_env(:poa_agent, :transfers, transfers)

    assert transfers == Application.fetch_env!(:poa_agent, :transfers)

    assert transfers == POAAgent.Configuration.Transfers.config()

    # putting back the original value
    :ok = Application.put_env(:poa_agent, :transfers, original_transfers)

    assert original_transfers == Application.fetch_env!(:poa_agent, :transfers)
  end

  test "Transfers overlay, default is an empty list" do
    original_transfers = Application.fetch_env!(:poa_agent, :transfers)

    transfers = []

    :ok = Application.put_env(:poa_agent, :transfers, transfers)

    assert transfers == Application.fetch_env!(:poa_agent, :transfers)

    assert transfers == POAAgent.Configuration.Transfers.config()

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

    # those values are in the test/poa_agent/config_overlay.json file
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

  test "Collectors overlay all fields [many collectors]" do
    original_collectors = Application.fetch_env!(:poa_agent, :collectors)

    collectors = [
       {:eth_information, POAAgent.Plugins.Collectors.Eth.Information, 60_000, :eth_information, [
          url: "http://localhost:8545",
          name: "Elixir-NodeJS-Integration",
          contact: "myemail@gmail.com"
          ]
       },
       {:other_collector, POAAgent.Plugins.Collectors.Eth.Information, 60_000, :eth_information, [
          url: "http://localhost:8545",
          name: "Elixir-NodeJS-Integration",
          contact: "myemail@gmail.com"
          ]
       }
     ]

    :ok = Application.put_env(:poa_agent, :collectors, collectors)

    assert collectors == Application.fetch_env!(:poa_agent, :collectors)

    # those values are in the test/poa_agent/config_overlay.json file
    new_url = "http://localhost:8546"
    new_name = "NewNodeName"
    new_contact = "mynewemail@gmail.com"

    [{:eth_information, POAAgent.Plugins.Collectors.Eth.Information, 60_000, :eth_information, new_args} | _] = POAAgent.Configuration.Collectors.config()

    assert new_url == new_args[:url]
    assert new_name == new_args[:name]
    assert new_contact == new_args[:contact]

    # putting back the original value
    :ok = Application.put_env(:poa_agent, :collectors, original_collectors)

    assert original_collectors == Application.fetch_env!(:poa_agent, :collectors)
  end

  test "test coverage for collectors" do
    original_collectors = Application.fetch_env!(:poa_agent, :collectors)
    original_config_overlay = Application.fetch_env!(:poa_agent, :config_overlay)

    collectors = [
       {:eth_information, POAAgent.Plugins.Collectors.Eth.Information, 60_000, :eth_information, [
          url: "http://localhost:8545",
          name: "Elixir-NodeJS-Integration",
          contact: "myemail@gmail.com"
          ]
       },
       {:other_collector, POAAgent.Plugins.Collectors.Eth.Information, 60_000, :eth_information, [
          url: "http://localhost:8545",
          name: "Elixir-NodeJS-Integration",
          contact: "myemail@gmail.com"
          ]
       }
     ]

    :ok = Application.put_env(:poa_agent, :collectors, collectors)

    assert collectors == Application.fetch_env!(:poa_agent, :collectors)

    :ok = Application.delete_env(:poa_agent, :config_overlay)

    assert collectors == POAAgent.Configuration.Collectors.config()

    # putting back the original value
    :ok = Application.put_env(:poa_agent, :collectors, original_collectors)
    :ok = Application.put_env(:poa_agent, :config_overlay, original_config_overlay)

    assert original_collectors == Application.fetch_env!(:poa_agent, :collectors)
  end

  test "test coverage for transfers" do
    original_transfers = Application.fetch_env!(:poa_agent, :transfers)
    original_config_overlay = Application.fetch_env!(:poa_agent, :config_overlay)

    transfers = []

    :ok = Application.put_env(:poa_agent, :transfers, transfers)

    assert transfers == Application.fetch_env!(:poa_agent, :transfers)

    :ok = Application.delete_env(:poa_agent, :config_overlay)

    assert transfers == POAAgent.Configuration.Transfers.config()

    # putting back the original value
    :ok = Application.put_env(:poa_agent, :transfers, original_transfers)

    assert original_transfers == Application.fetch_env!(:poa_agent, :transfers)
    :ok = Application.put_env(:poa_agent, :config_overlay, original_config_overlay)
  end
end
