defmodule POAAgent.Plugins.Collectors.Supervisor do
  @moduledoc false

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    import Supervisor.Spec

    # create the children from the config file
    collectors = Application.get_env(:poa_agent, :collectors)
    mappings = Application.get_env(:poa_agent, :mappings)

    children = for {name, module, label, args} <- collectors do
      worker(module, [%{name: name, transfers: mappings[name], label: label, args: args}])
    end

    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end

end