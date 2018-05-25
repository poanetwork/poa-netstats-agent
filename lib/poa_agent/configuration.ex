defmodule POAAgent.Configuration do
  def get_config_from_file do
    file_name = Application.get_env(:poa_agent, :config_file)
    string = File.read!(file_name)
    Poison.decode!(string)
  end

  def transform_transfer_configuration(data) do
    id = String.to_atom(Map.fetch!(data, "id"))
    module = String.to_existing_atom("Elixir" <> "." <> Map.fetch!(data, "module"))
    args = data
    |> Map.fetch!("args")
    |> Enum.into(Keyword.new(), &atomify_key/1)
    {id, module, args}
  end

  def normalize(data) do
    case data["POAAgent"]["transfers"] do
      [] ->
        []
      x when is_list(x) ->
        Enum.map(x, &POAAgent.Configuration.transform_transfer_configuration/1)
    end
  end

  def consolidate(old, new) do
    consolidate_one_by_one = fn {id, module, args} = spec ->
      id_index = 0
      case List.keyfind(old, id, id_index) do
        nil ->
          spec
        {^id, _, old_args} ->
          {id, module, Keyword.merge(old_args, args)}
      end
    end
    Enum.map(new, consolidate_one_by_one)
  end

  defp atomify_key({k, v}) do
    {String.to_existing_atom(k), v}
  end
end
