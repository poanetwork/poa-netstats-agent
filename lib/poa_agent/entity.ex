defmodule POAAgent.Entity do
  @moduledoc false

  defmodule Name do
    @moduledoc false

    def change({old, new}, data) do
      {value, data} = Map.pop(data, old)
      Map.put(data, new, value)
    end
  end

  defprotocol NameConvention do
    def from_elixir_to_node(x)
  end
end
