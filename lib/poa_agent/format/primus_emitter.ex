defmodule POAAgent.Format.PrimusEmitter do
  @moduledoc false

  def wrap(data, event: e) do
    %{emit: [e | [data]]}
  end

end
