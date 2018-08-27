defmodule POAAgent.Entity.ProtocolTest do
  use ExUnit.Case

  alias POAAgent.Format.POAProtocol.Data
  alias POAAgent.Entity.Ethereum.Block
  alias POAAgent.Entity.Ethereum.History
  alias POAAgent.Entity.Ethereum.Pending
  alias POAAgent.Entity.Ethereum
  alias POAAgent.Entity.Host.Information
  alias POAAgent.Entity.Host.Latency
  alias POAAgent.Entity.System
  alias POAAgent.Entity
  
  test "Data protocol test for block entity" do
    entity = %Block{}
    formated_entity = format_entity(entity)

    assert %Data{type: "block", body: formated_entity} == Data.Format.to_data(entity)
  end

  test "Data protocol test for information entity" do
    entity = %Information{}
    formated_entity = format_entity(entity)

    assert %Data{type: "information", body: formated_entity} == Data.Format.to_data(entity)
  end

  test "Data protocol test for history entity" do
    entity = %History{}
    formated_entity = Map.from_struct(entity)

    assert %Data{type: "history", body: formated_entity} == Data.Format.to_data(entity)
  end

  test "Data protocol test for pending entity" do
    entity = %Pending{}
    formated_entity = format_entity(entity)

    assert %Data{type: "pending", body: formated_entity} == Data.Format.to_data(entity)
  end

  test "Data protocol test for statistics entity" do
    entity = %Ethereum.Statistics{}
    formated_entity = format_entity(entity)

    assert %Data{type: "statistics", body: formated_entity} == Data.Format.to_data(entity)
  end

  test "Data protocol test for latency entity" do
    entity = %Latency{}
    formated_entity = format_entity(entity)

    assert %Data{type: "latency", body: formated_entity} == Data.Format.to_data(entity)
  end

  test "Data protocol test for System Stats entity" do
    entity = %System.Statistics{}
    formated_entity = format_entity(entity)

    assert %Data{type: "statistics", body: formated_entity} == Data.Format.to_data(entity)
  end

  defp format_entity(entity) do
    entity
    |> Entity.NameConvention.from_elixir_to_node()
  end

end