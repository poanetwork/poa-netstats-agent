defmodule POAAgent.Configuration do
  @moduledoc false

  defmodule Transfers do
    @moduledoc false

    def config do
      elixir_config = Application.fetch_env!(:poa_agent, :transfers)
      case Application.fetch_env(:poa_agent, :config_overlay) do
        :error ->
          elixir_config
        {:ok, path} when is_binary(path) ->
          path
          |> File.read!()
          |> Jason.decode!()
          |> config(elixir_config)
      end
    end

    defp config(_, []) do
      []
    end

    defp config(overlay, default) do
      overlay
      |> Kernel.get_in(["POAAgent", "transfers"])
      |> Kernel.hd()
      |> merge_overlay_into_config(default)
    end

    defp merge_overlay_into_config(overlay, [{id, module_name, default}]) do
      keys = [
        "address",
        "identifier",
        "secret"
      ]
      ^id = String.to_existing_atom(Map.fetch!(overlay, "id"))
      restricted = Map.take(overlay, keys)
      want = POAAgent.Configuration.to_keyword(restricted)
      final = Keyword.merge(default, want)
      [{id, module_name, final}]
    end
  end

  defmodule Collectors do
    @moduledoc false

    def config do
      elixir_config = Application.fetch_env!(:poa_agent, :collectors)
      case Application.fetch_env(:poa_agent, :config_overlay) do
        :error ->
          elixir_config
        {:ok, path} when is_binary(path) ->
          path
          |> File.read!()
          |> Jason.decode!()
          |> config(elixir_config)
      end
    end

    defp config(_, []) do
      []
    end

    defp config(overlay, default) do
      overlay
      |> Kernel.get_in(["POAAgent", "collectors"])
      |> Kernel.hd()
      |> merge_overlay_into_config(default)
    end

    defp merge_overlay_into_config(overlay, [{id, module_name, freq, tag, default}]) do
      keys = [
        "url",
        "name",
        "contact"
      ]
      ^id = String.to_existing_atom(Map.fetch!(overlay, "id"))
      restricted = Map.take(overlay, keys)
      want = POAAgent.Configuration.to_keyword(restricted)
      final = Keyword.merge(default, want)
      [{id, module_name, freq, tag, final}]
    end
  end

  def to_keyword(x) do
    f = fn {k, v} ->
      {String.to_existing_atom(k), v}
    end
    Enum.into(x, [], f)
  end
end
