defmodule POAAgent.Format do
  @moduledoc false

  defmodule Literal do
    @moduledoc false

    defmodule Hex do
      @moduledoc false

      ## A literal hex string like "0x0123456789abcdef"
      @type t :: String.t

      @spec decimalize(t) :: String.t | :format_error
      def decimalize("0x" <> trimmed_hex) do
        {integer, _} = Integer.parse(trimmed_hex, 16)
        Integer.to_string(integer)
      end
      def decimalize(_) do
        :format_error
      end
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
