defmodule POAAgent.Application do
  @moduledoc """

  This module implements the Application behaviour

  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(POAAgent.Plugins.Transfers.Supervisor, []),
      supervisor(POAAgent.Plugins.Collectors.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: POAAgent.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
