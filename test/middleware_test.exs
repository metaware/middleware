defmodule MiddlewareTest do
  use ExUnit.Case
  doctest Middleware

  alias Middleware.Band
  alias Middleware.Nea

  test "integration" do
    Nea.start_link(:nea1)
    Band.start_link(:band1)
    {:ok, provisioning_id} = Band.provision(:band1)
    Nea.pair(:nea1, "fake", :band1)
    {:ok, bands} = Nea.list_bands(:nea1)
    assert bands == %{}
    Nea.pair(:nea1, provisioning_id, :band1)
    {:ok, bands} = Nea.list_bands(:nea1)
    assert bands == %{ band1: true }
    IO.inspect(bands)
    Band.unpair(:band1)
    {:ok, bands} = Nea.list_bands(:nea1)
    assert bands == %{}
  end

end
