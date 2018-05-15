defmodule POAAgent.Utils do
  @moduledoc false

  @doc false
  def system_time do                                                                                                                                                                                   
    {mega, seconds, ms} = :os.timestamp()                                                                                                                                                               
    (mega * 1_000_000 + seconds) * 1000 + :erlang.round(ms / 1000)                                                                                                                                              
  end
end