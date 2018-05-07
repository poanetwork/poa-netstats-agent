defmodule POAAgent.Plugins.Collectors.Supervisor do
  @moduledoc false

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    import Supervisor.Spec

    # create the children from the config file
    collectors = Application.get_env(:poa_agent, :collectors)

    children = for {name, module, transfers, label, args} <- collectors do
      worker(module, [%{name: name, transfers: transfers, label: label, args: args}])
    end

    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end

end