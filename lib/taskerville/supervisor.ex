defmodule Taskerville.Supervisor do

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Taskerville.Scheduler.Server,
      Taskerville.TaskRunner.RunSupervisor,
      Taskerville.TaskRunner.Manager
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
