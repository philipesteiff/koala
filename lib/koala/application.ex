defmodule Koala.Application do

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Koala.Worker.start_link(arg)
      # {Koala.Worker, arg},
      worker(Koala.Robot.Slack, []),
      #      worker(Koala.Robot.Console, []),
      #      worker(Koala.Release.Train.Scheduler, [])
      #      worker(Koala.Mock, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Koala.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def env(key) do
    Application.get_env(:koala, Koala.Application)[key]
  end
end
