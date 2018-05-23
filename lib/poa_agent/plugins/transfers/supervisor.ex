defmodule POAAgent.Plugins.Transfers.Supervisor do
  @moduledoc false

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    import Supervisor.Spec

    # create the children from the config file
    transfers = Application.get_env(:poa_agent, :transfers)
    more = POAAgent.Configuration.get_config()
    transfers = case more["POAAgent"]["transfers"] do
                  [] ->
                    transfers
                  x when is_list(x) ->
                    Enum.map(x, &POAAgent.Configuration.transform_transfer/1)
                end
    children = for {name, module, args} <- transfers do
      worker(module, [%{name: name, args: args}])
    end

    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end

end
