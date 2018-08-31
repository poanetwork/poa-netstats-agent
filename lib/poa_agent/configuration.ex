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
      |> merge_overlay_into_config(default)
    end

    defp merge_overlay_into_config(overlay, default) do
      Enum.flat_map(default,
        fn {id, module_name, args} ->
          case POAAgent.Configuration.search(overlay, Atom.to_string(id)) do
            [] ->
              []
            overlay_args ->
              overlay_args = POAAgent.Configuration.to_keyword(overlay_args)
              final = Keyword.merge(args, overlay_args)
              [{id, module_name, final}]
          end
        end)
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
      |> merge_overlay_into_config(default)
    end

    defp merge_overlay_into_config(overlay, default) do
      Enum.flat_map(default,
        fn {id, module_name, freq, tag, args} ->
          case POAAgent.Configuration.search(overlay, Atom.to_string(id)) do
            [] ->
              []
            overlay_args ->
              overlay_args = POAAgent.Configuration.to_keyword(overlay_args)
              final = Keyword.merge(args, overlay_args)
              [{id, module_name, freq, tag, final}]
          end
        end)
    end
  end

  def to_keyword(nil), do: []
  def to_keyword(x) do
    f = fn {k, v} ->
      {String.to_atom(k), v}
    end
    Enum.into(x, [], f)
  end

  def search(list, key) do
    Enum.find(list, fn(map) ->
      Map.get(map, "id") == key
    end)
  end
end
