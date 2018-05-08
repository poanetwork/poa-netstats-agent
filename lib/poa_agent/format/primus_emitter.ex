defmodule POAAgent.Format.PrimusEmitter do
  @moduledoc false

  def write(id: i, event: e, name: n, data: d) do
    value = %{"id" => i, n => d}
    %{emit: [e, value]}
  end

  def write(id: i, event: e, name: n, data: d, secret: s) do
    value = %{"id" => i, n => d, "secret" => s}
    %{emit: [e, value]}
  end
end
