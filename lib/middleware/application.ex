defmodule Middleware.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(Registry, [:unique, :nea_registry], id: :nea_registry),
      supervisor(Registry, [:unique, :band_registry], id: :band_registry)
      # Starts a worker by calling: Middleware2.Worker.start_link(arg1, arg2, arg3)
      # worker(Middleware2.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Middleware.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
