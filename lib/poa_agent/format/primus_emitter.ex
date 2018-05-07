defmodule POAAgent.Format.PrimusEmitter do
  @moduledoc false

  def write(event: e, data: d) do
    %{emit: [e, d]}
  end
end
