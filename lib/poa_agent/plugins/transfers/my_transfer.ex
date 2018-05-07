defmodule POAAgent.Plugins.Transfers.MyTransfer do
  use POAAgent.Plugins.Transfer

  def init_transfer(args) do
    IO.puts "init_transfer args = #{inspect args}"
    {:ok, :no_state}
  end

  def data_received(label, data, state) do
    IO.puts "Received data with label #{inspect label}, data #{inspect data} and internal_state #{inspect state}"
    {:ok, :no_state}
  end

  def terminate(_reason, _state) do
    :ok
  end

end