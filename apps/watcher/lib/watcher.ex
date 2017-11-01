defmodule Watcher do
  @moduledoc """
  Documentation for Watcher.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Watcher.Worker.start_link(arg)
      # {Watcher.Worker, arg},
      worker(Watcher.FeedWatcher, ["https://news.ycombinator.com/rss"])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Watcher.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
