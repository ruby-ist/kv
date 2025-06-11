defmodule KVServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4040")
    children = [
      {Task.Supervisor, name: KVServer.TaskSupervisor},
      # Tasks, by default, have the :restart value set to :temporary, which means they are not restarted.
      # This means if acceptor crashes, new one will not take its place
      # So, we need to change that strategy with Supervisor.child_spec/2
      Supervisor.child_spec({Task, fn -> KVServer.accept(port) end}, restart: :permanent)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KVServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
