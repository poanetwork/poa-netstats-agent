defmodule POAAgent.Plugins.Collectors.MyCollector do
  use POAAgent.Plugins.Collector

  def init_collector(args) do
    IO.puts "init_collector args = #{inspect args}"
    {:ok, :no_state}
  end

  def collect(:no_state) do
    IO.puts "I am collecting data!"
    {:ok, "data retrieved", :no_state}
  end

  def terminate(_state) do
    :ok
  end

end