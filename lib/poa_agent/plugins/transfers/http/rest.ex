defmodule POAAgent.Plugins.Transfers.HTTP.REST do
  @moduledoc false

  use POAAgent.Plugins.Transfer

  alias __MODULE__
  alias POAAgent.Format.POAProtocol.Data
  alias POAAgent.Entity.Host.Latency

  require Logger

  defmodule State do
    @moduledoc false

    defstruct [
      address: nil,
      identifier: nil,
      user: nil,
      password: nil,
      token_url: nil,
      token: "",
      ping_timer_ref: nil
    ]
  end

  @ping_frequency 3_000
  @content_type_header {"Content-Type", "application/msgpack"}

  def init_transfer(configuration) do
    state = struct(REST.State, configuration)
    set_ping_timer()
    {:ok, state}
  end

  def data_received(label, metric_type, data, state) when is_list(data) do
    require Logger
    Logger.info("Received data from the collector referenced by label: #{label}.")

    state = Enum.reduce(data, state, fn(message, state) ->
      {_, state} = send_metric(message, metric_type, state)

      state
    end)

    {:ok, state}
  end

  def data_received(label, metric_type, data, state) do
    data_received(label, metric_type, [data], state)
  end

  def terminate(_) do
    :ok
  end

  def handle_message(:ping, state) do
    url = "/ping"

    event = %{}
      |> Map.put(:id, state.identifier)
      |> Msgpax.pack!()

    before_ping = POAAgent.Utils.system_time()

    {_, state} =
      case post(state.address <> url, event, state) do
        {%HTTPoison.Response{status_code: 200}, state} ->
          latency = (POAAgent.Utils.system_time() - before_ping) / 1
          send_latency(latency, state)
        {_, state} ->
          {:ok, state}
      end

    ping_timer_ref = set_ping_timer()

    {:ok, %State{state | ping_timer_ref: ping_timer_ref}}
  end

  defp send_latency(latency, state) do

    latency
    |> Latency.new
    |> send_metric("networking_metrics", state)
  end

  defp send_metric(metric, metric_type, state) do
    url = "/data"

    data =
      metric
      |> Data.Format.to_data()
      |> Map.from_struct()

    event =
      %{}
      |> Map.put(:id, state.identifier)
      |> Map.put(:type, metric_type)
      |> Map.put(:data, data)
      |> Msgpax.pack!()

      post(state.address <> url, event, state)
  end

  defp post(address, event, state) do
    headers = [@content_type_header, bearer_auth_header(state.token)]

    case HTTPoison.post(address, event, headers) do
      {:ok, %HTTPoison.Response{status_code: 200} = result} ->
        {result, state}
      {:ok, %HTTPoison.Response{status_code: 401}} ->
        Logger.warn("Error 401, getting a new Token")
        jwt_token = new_token(state)
        result = HTTPoison.post(address, event, [@content_type_header, bearer_auth_header(jwt_token)])
        {result, %State{state | token: jwt_token}}
      {:ok, %HTTPoison.Response{status_code: error} = result} ->
        Logger.warn("Error sending with POST, code #{inspect error}")
        {result, state}
      {:error, %HTTPoison.Error{reason: reason} = result} ->
        Logger.warn("Error unexpected sending with POST, the reason is #{inspect reason}")
        {result, state}
    end
  end

  defp new_token(state) do
    headers = [@content_type_header, basic_auth_header(state.user, state.password)]
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]

    body =
      %{}
      |> Map.put(:'agent-id', state.identifier)
      |> Msgpax.pack!()

    case HTTPoison.post(state.token_url, body, headers, options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body_decoded = Poison.decode!(body)
        body_decoded["token"]
      _ ->
        ""
    end
  end

  defp set_ping_timer() do
    Process.send_after(self(), :ping, @ping_frequency)
  end

  defp bearer_auth_header(token) do
    {"Authorization", "Bearer " <> token}
  end

  defp basic_auth_header(user, password) do
    {"Authorization", "Basic " <> Base.encode64(user <> ":" <> password)}
  end
end