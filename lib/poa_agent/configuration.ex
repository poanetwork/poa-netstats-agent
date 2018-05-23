defmodule POAAgent.Configuration do
  def get_config do
    file_name = Application.get_env(:poa_agent, :config_file)
    string = File.read!(file_name)
    Poison.decode!(string)
  end

  def transform_transfer(data) do
    id = String.to_atom(Map.fetch!(data, "id"))
    module = String.to_existing_atom("Elixir" <> "." <> Map.fetch!(data, "module"))
    args = data
    |> Map.fetch!("args")
    |> Enum.into(Keyword.new(), &atomify_key/1)
    {id, module, args}
  end

  defp atomify_key({k, v}) do
    {String.to_existing_atom(k), v}
  end
end
