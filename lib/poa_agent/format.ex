defmodule POAAgent.Format do
  @moduledoc false

  defmodule Literal do
    @moduledoc false

    defmodule Hex do
      @moduledoc false

      ## A literal hex string like "0x0123456789abcdef"
      @type t :: String.t
    end

    defmodule TrimmedHex do
      @moduledoc false

      ## A literal hex string like "0123456789abcdef" w/o the leading
      ## "0x" indicator
      @type t :: String.t
    end

    defmodule Decimal do
      @moduledoc false

      ## A literal decimal string like "0123456789"
      @type t :: String.t
    end
  end
end
