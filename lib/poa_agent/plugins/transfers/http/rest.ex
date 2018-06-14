defmodule POAAgent.Plugins.Transfers.HTTP.REST do
  @moduledoc false

  use POAAgent.Plugins.Transfer

  alias __MODULE__
  alias POAAgent.Format.POAProtocol.Data

  require Logger

  defmodule State do
    @moduledoc false

    defstruct [
      address: nil,
      identifier: nil,
      secret: nil,
      ping_timer_ref: nil,
      last_metrics: %{}
    ]
  end

  @ping_frequency 3_000

  def init_transfer(configuration) do
    state = struct(REST.State, configuration)
    set_ping_timer()
    {:ok, state}
  end

  def data_received(label, data, state) when is_list(data) do
    require Logger
    Logger.info("Received data from the collector referenced by label: #{label}.")

    last_metrics = Enum.reduce(data, state.last_metrics, fn(message, metrics) ->
      send_metric(message, state)

      Map.put(metrics, label, message)
    end)

    {:ok, %{state | last_metrics: last_metrics}}
  end

  def data_received(label, data, state) do
    data_received(label, [data], state)
  end

  def terminate(_) do
    :ok
  end

  def handle_message(:ping, state) do
    url = "/ping"

    event = %{}
      |> Map.put(:id, state.identifier)
      |> Map.put(:secret, state.secret)
      |> Jason.encode!()

    before_ping = POAAgent.Utils.system_time()

    case post(state.address <> url, event) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        latency = (POAAgent.Utils.system_time() - before_ping) / 1
        send_latency(state, latency)
      {:ok, %HTTPoison.Response{status_code: error}} ->
        Logger.warn("Error sending a ping code #{inspect error}")
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.warn("Error sending a ping reason #{inspect reason}")
    end

    ping_timer_ref = set_ping_timer()

    {:ok, %{state | ping_timer_ref: ping_timer_ref}}
  end

  defp send_latency(state, latency) do
    url = "/latency"

    event = %{}
      |> Map.put(:id, state.identifier)
      |> Map.put(:secret, state.secret)
      |> Map.put(:latency, latency)
      |> Jason.encode!()

      post(state.address <> url, event)
  end

  defp send_metric(metric, state) do
    url = "/data"

    data = metric
      |> Data.Format.to_data()
      |> Map.from_struct()

    event =
      %{}
      |> Map.put(:id, state.identifier)
      |> Map.put(:secret, state.secret)
      |> Map.put(:type, "ethereum_metrics") # for now only ethereum_metrics
      |> Map.put(:data, data)
      |> Jason.encode!()

      post(state.address <> url, event)
  end

  defp post(address, event) do
    HTTPoison.post(address, event, [{"Content-Type", "application/json"}])
  end

  defp set_ping_timer() do
    Process.send_after(self(), :ping, @ping_frequency)
  end

end