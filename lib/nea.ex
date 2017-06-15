defmodule Middleware.Nea do
  use GenServer  

  alias Middleware.Band

  require IEx

  # Client API
  def start_link(nea_id) do
    GenServer.start_link(__MODULE__, %{}, name: {:global, nea_id})
  end

  def notify(nea_id, event, { band_id, payload }) do
    GenServer.call({:global, nea_id }, { event, { band_id, payload } })
  end

  def pair(nea_id, provisioning_id, band_id) do
    GenServer.call({:global, nea_id}, { :pair, provisioning_id, band_id })
  end

  def unpair(nea_id, band_id) do
    GenServer.call({:global, nea_id }, { :unpair, band_id })
  end

  def list_bands(nea_id) do
    GenServer.call({:global, nea_id}, :list_bands)
  end

  # Server API
  def handle_call({:clasp, { band_id, payload }}, _from, state) do
    IO.puts("Band Clasped: #{band_id}")
    {:reply, :ok, state}
  end

  def handle_call({:authenticate, { band_id, payload }}, _from, state) do
    IO.puts("Band Authenticated: #{band_id}")
    {:reply, :ok, state}
  end

  def handle_call({ :provisioning_started, { band_id, provisioning_id }}, _from, state) do
    IO.puts("Band Entered Provisioning Mode, discovered provisioning key: #{provisioning_id}")
    { :reply, :ok, state }
  end

  def handle_call({ :pair, provisioning_id, band_id }, _from, state) do
    case Band.pair(band_id, provisioning_id) do
      { :ok, _ } -> { :reply, :ok, Map.put(state, band_id, true) }
      { :error, _ } -> { :reply, :error, state}
    end
  end

  def handle_call({ :unpair, band_id }, _from, state) do
    IO.puts("Band #{band_id} unpaired.")
    state = Map.delete(state, band_id)
    {:reply, {:ok, state}, state}
  end

  def handle_call(:list_bands, _from, state) do
    {:reply, {:ok, state}, state}
  end
  
end