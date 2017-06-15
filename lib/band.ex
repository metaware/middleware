defmodule Middleware.Band do
  use GenServer
  alias Middleware.Nea
  
  @nea_id :nea1

  # Client API
  def start_link(band_id) do
    GenServer.start_link(__MODULE__, %{}, name: {:global, band_id})
  end

  def trigger_event(band_id, event, payload) do
    GenServer.call({:global, band_id}, { event, band_id, payload })
  end

  def provision(band_id) do
    GenServer.call({:global, band_id}, { :provision, band_id })
  end

  def pair(band_id, provisioning_id) do
    GenServer.call({:global, band_id}, { :pair, provisioning_id })
  end

  def unpair(band_id) do
    GenServer.call({:global, band_id}, { :unpair, band_id })
  end

  # Server API
  def handle_call({ event, band_id, payload}, _from, state) do
    Nea.notify(@nea_id, event, { band_id, payload })
    { :reply, :ok, state }
  end

  def handle_call({ :provision, band_id }, _from, state) do
    provisioning_id = :crypto.strong_rand_bytes(6) 
      |> :base64.encode_to_string
    Nea.notify(@nea_id, :provisioning_started, { band_id, provisioning_id })
    {:reply, { :ok, provisioning_id }, Map.put(state, :provisioning_id, provisioning_id) }
  end

  def handle_call({ :pair, provisioning_id}, _from, state) do
    case state[:provisioning_id] == provisioning_id do
      true ->  {:reply, { :ok, state }, Map.put(state, :paired, true)}
      false -> {:reply, { :error, state }, state}
    end
  end

  def handle_call({ :unpair, band_id }, _from, state) do
    case Nea.unpair(@nea_id, band_id) do
      {:ok, _} -> {:reply, :ok, state}
      _ -> IO.puts('Unpairing Failed')
    end
  end

end