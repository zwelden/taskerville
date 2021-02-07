defmodule Taskerville.TaskRunner.Manager do
  @name __MODULE__

  require Logger

  alias Taskerville.TaskRunner.RunSupervisor

  use GenServer

  # Client Functions

  def start_link(_args) do
    Logger.info("Starting the Task Runner Server...")
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  def run(task_name, func) do
    GenServer.cast @name, {:run, task_name, func}
  end

  def task_completed(pid) do
    GenServer.cast @name, {:complete, pid}
  end

  # Server Functions

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:run, task_name, func}, state) do
    Logger.info "Staging task #{task_name}"
    {:ok, child} = RunSupervisor.start_child(func)
    Logger.debug "Child started: #{inspect child}"
    {:noreply, state}
  end

  def handle_cast({:complete, pid}, state) do
    Logger.info "Task Complete: #{inspect pid}"
    {:noreply, state}
  end
end
