defmodule POAAgent.Plugins.Transfers.DB.Mnesia do
  @moduledoc false

  use POAAgent.Plugins.Transfer
  alias POAAgent.Entity.System.Metric

  @doc false
  @spec init_transfer(term()) :: {:ok, none()}
  def init_transfer(_args) do
    :application.ensure_all_started(:mnesia)
    _ = :mnesia.create_schema([node()])
    _ = :mnesia.create_table(:metrics,[attributes: [:os_type, :unix_process,
                                                     :cpu_util, :disk_util,
                                                     :memsup]])
    {:ok, :no_state}
  end

  @doc false
  @spec data_received(atom(), term(), none()) :: term()
  def data_received(_label, data, _state) do
    {:atomic, :ok} = store_data(data)
    {:ok, :no_state}
  end

  @doc false
  @spec handle_message(atom(), term()) :: term()
  def handle_message(_message, state) do
    {:ok, state}
  end

  @doc false
  @spec terminate(term()) :: :ok
  def terminate(_state) do
    :ok
  end

  @doc false
  defp store_data(data) do
    :mnesia.transaction(fn -> :mnesia.write(:metrics, data.os_type,
                                            data.unix_process, data.cpu_util,
                                            data.disk_used, data.memsup
                                            ) end)
  end
end