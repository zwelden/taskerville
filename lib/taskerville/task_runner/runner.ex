defmodule Taskerville.TaskRunner.Runner do

  alias Taskerville.TaskRunner.Manager

  use GenServer, restart: :transient

  # Client Functions

  def start_link({task_name, task_def}) do
    GenServer.start_link(__MODULE__, {task_name, task_def})
  end

  # Server Functions

  def init({task_name, {func, args}}) do
    {:ok, [], {:continue, {task_name, {func, args}}}}
  end

  def init({task_name, {mod, func, args}}) do
    {:ok, [], {:continue, {task_name, {mod, func, args}}}}
  end

  def handle_continue({task_name, {func, args}}, state) do
    apply(func, args)
    Manager.task_completed(task_name, self())
    {:stop, :normal, state}
  end

  def handle_continue({task_name, {mod, func, args}}, state) do
    apply(mod, func, args)
    Manager.task_completed(task_name, self())
    {:stop, :normal, state}
  end
end
