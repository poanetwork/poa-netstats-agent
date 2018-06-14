defmodule POAAgent.Format.POAProtocol.Data do
  @moduledoc false

  @type t :: %__MODULE__{
    type: String.t | nil,
    body: Map.t
  }

  defstruct [
    type: nil,
    body: %{}
  ]

  def new(type, body) when is_binary(type) and is_map(body) do
    body = case Map.has_key?(body, :__struct__) do
      true -> Map.from_struct(body)
      false -> body
    end

    %__MODULE__{
      type: type,
      body: body
    }
  end

  defprotocol Format do
    def to_data(x)
  end
end