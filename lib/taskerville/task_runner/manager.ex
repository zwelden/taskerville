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

  def run(task_name, max_concurrent, task_def) do
    GenServer.cast @name, {:run, task_name, max_concurrent, task_def}
  end

  def task_completed(task_name, pid) do
    GenServer.cast @name, {:complete, {task_name, pid}}
  end

  def get_running_tasks do
    GenServer.call @name, :get_running_tasks
  end

  # Server Functions

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:run, task_name, 0, task_def}, state) do
    Logger.info "Staging task #{task_name}"
    {:ok, child} = RunSupervisor.start_child({task_name, task_def})
    new_state = Map.update(state, task_name, [child], fn(lst) -> [child | lst] end)
    {:noreply, new_state}
  end

  def handle_cast({:run, task_name, max_concurrent, task_def}, state) when is_integer(max_concurrent) do
    Logger.info "Staging task #{task_name}"

    num_same_tasks = Map.get(state, task_name, []) |> length

    if num_same_tasks < max_concurrent do
      {:ok, child} = RunSupervisor.start_child({task_name, task_def})
      new_state = Map.update(state, task_name, [child], fn(lst) -> [child | lst] end)
      {:noreply, new_state}
    else
      Logger.info "Too many concurrent tasks for #{task_name}. Skipping"
      {:noreply, state}
    end
  end

  def handle_cast({:complete, {task_name, pid}}, state) do
    Logger.info "Task Complete: #{inspect pid}, task name: #{task_name}"
    new_state = Map.update(state, task_name, [], fn (lst) -> lst -- [pid] end)
    {:noreply, new_state}
  end

  def handle_call(:get_running_tasks, _from, state) do
    {:reply, state, state}
  end
end
