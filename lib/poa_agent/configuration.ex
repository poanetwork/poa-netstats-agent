defmodule POAAgent.Configuration do
  @moduledoc false

  def transfers do
    elixir_config = Application.fetch_env!(:poa_agent, :transfers)
    case Application.fetch_env(:poa_agent, :transfer_config_overlay) do
      :error ->
        elixir_config
      {:ok, path} when is_binary(path) ->
        path
        |> File.read!()
        |> Jason.decode!()
        |> transfers(elixir_config)
    end
  end

  def transfers(_, []) do
    []
  end

  def transfers(overlay, default) do
    overlay
    |> Kernel.get_in(["POAAgent", "transfers"])
    |> Kernel.hd()
    |> merge_overlay_into_config(default)
  end

  defp merge_overlay_into_config(overlay, [{id, module_name, default}]) do
    keys = [
      "address",
      "identifier",
      "name",
      "secret",
      "contact"
    ]
    ^id = String.to_existing_atom(Map.fetch!(overlay, "id"))
    restricted = Map.take(overlay, keys)
    want = to_keyword(restricted)
    final = Keyword.merge(default, want)
    [{id, module_name, final}]
  end

  defp to_keyword(x) do
    f = fn {k, v} ->
      {String.to_existing_atom(k), v}
    end
    Enum.into(x, [], f)
  end
end
