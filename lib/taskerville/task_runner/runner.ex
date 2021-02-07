defmodule Taskerville.TaskRunner.Runner do

  alias Taskerville.TaskRunner.Manager

  use GenServer, restart: :transient

  # Client Functions

  def start_link(func) do
    GenServer.start_link(__MODULE__, func)
  end

  # Server Functions

  def init(func) do
    {:ok, [], {:continue, func}}
  end

  def handle_continue(func, state) do
    func.()
    Manager.task_completed(self())
    {:stop, :normal, state}
  end
end
