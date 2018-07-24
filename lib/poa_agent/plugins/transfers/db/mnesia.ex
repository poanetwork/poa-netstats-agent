defmodule POAAgent.Plugins.Transfers.DB.Mnesia do
  @moduledoc false

  use POAAgent.Plugins.Transfer

  alias __MODULE__
  alias POAAgent.Entity.System.Metric

  defmodule State do
    @moduledoc false

    defstruct [
      table_name: nil,
      fields: nil,
    ]
  end

  @doc false
  @spec init_transfer(term()) :: {:ok, State}
  def init_transfer(args) do
    state = struct(Mnesia.State, args)

    :application.ensure_all_started(:mnesia)
    _ = :mnesia.create_schema([node()])
    _ = :mnesia.create_table(state.table_name, [attributes: state.fields])
    {:ok, state}
  end

  @doc false
  @spec data_received(atom(), term(), none()) :: term()
  def data_received(_label, data, state) do
    {:atomic, :ok} = store_data(state, data)
    {:ok, state}
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
  defp store_data(state, data) do
    :mnesia.transaction(fn -> :mnesia.write({state.table_name, data.timestamp,
                                            data.os_type, data.unix_process,
                                            data.cpu_util, data.disk_used,
                                            data.memsup}) end)
  end
end