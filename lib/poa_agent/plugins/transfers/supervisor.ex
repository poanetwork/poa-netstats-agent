defmodule POAAgent.Plugins.Transfers.Supervisor do
  @moduledoc false

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    import Supervisor.Spec

    # create the children from the config file
    transfers = POAAgent.Configuration.transfers()
    children = for {name, module, args} <- transfers do
      worker(module, [%{name: name, args: args}])
    end

    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end
end
