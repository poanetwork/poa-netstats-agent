defmodule EchoTransfer do
  @moduledoc false

  use POAAgent.Plugins.Transfer

  def start(name) do
    EchoTransfer.start_link(%{name: name, args: self()})
  end

  def init_transfer(caller) do
    {:ok, caller}
  end

  def data_received(label, _metric_type, data, caller) do
    send(caller, {label, data})
    {:ok, caller}
  end

  def handle_message(_, state) do
    {:ok, state}
  end

  def terminate(_state) do
    :ok
  end
end
