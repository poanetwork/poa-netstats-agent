defmodule POAAgent.Entity.ProtocolTest do
  use ExUnit.Case

  alias POAAgent.Format.POAProtocol.Data
  alias POAAgent.Entity.Ethereum.Block
  alias POAAgent.Entity.Ethereum.History
  alias POAAgent.Entity.Ethereum.Pending
  alias POAAgent.Entity.Ethereum.Statistics
  alias POAAgent.Entity.Host.Information
  
  test "Data protocol test for block entity" do
    entity = %Block{}
    formated_entity = Map.from_struct(entity)

    assert %Data{type: "block", body: formated_entity} == Data.Format.to_data(entity)
  end

  test "Data protocol test for information entity" do
    entity = %Information{}
    formated_entity = Map.from_struct(entity)

    assert %Data{type: "information", body: formated_entity} == Data.Format.to_data(entity)
  end

  test "Data protocol test for history entity" do
    entity = %History{}
    formated_entity = Map.from_struct(entity)

    assert %Data{type: "history", body: formated_entity} == Data.Format.to_data(entity)
  end

  test "Data protocol test for pending entity" do
    entity = %Pending{}
    formated_entity = Map.from_struct(entity)

    assert %Data{type: "pending", body: formated_entity} == Data.Format.to_data(entity)
  end

  test "Data protocol test for statistics entity" do
    entity = %Statistics{}
    formated_entity = Map.from_struct(entity)

    assert %Data{type: "statistics", body: formated_entity} == Data.Format.to_data(entity)
  end

end