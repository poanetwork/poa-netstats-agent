defmodule POAAgen.Plugins.Collectors.System.Metrics do
  use POAAgent.Plugins.Collector

  @moduledoc """
  Nice describe
  """
  def init_collector(_args) do
    {:ok, :no_state}
  end

  def collect(:no_state) do
    {:transfer, metrics(), :no_state}
  end

  def terminate(_state) do
    :ok
  end

  defp metrics() do
    :erlang.memory()
  end
end