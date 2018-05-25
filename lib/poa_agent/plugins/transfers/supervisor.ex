defmodule POAAgent.Plugins.Transfers.Supervisor do
  @moduledoc false

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    import Supervisor.Spec

    transfers = configure()
    children = for {name, module, args} <- transfers do
      worker(module, [%{name: name, args: args}])
    end

    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end

  defp configure do
    old = Application.get_env(:poa_agent, :transfers)
    more = POAAgent.Configuration.get_config_from_file()
    new = POAAgent.Configuration.normalize(more)
    POAAgent.Configuration.consolidate(old, new)
  end
end
