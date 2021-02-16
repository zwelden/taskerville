defmodule Taskerville do
  @moduledoc """
  Documentation for `Taskerville`.
  """

  require Logger

  @doc """
  Starts the Taskerville Scheduler Server processes.

  Returns {:ok, pid}

  ## Examples
    iex> {:ok, pid} = Taskerville.start()
    iex> is_pid(pid)
    true
  """
  def start do
    Logger.info("Starting Taskerville...")
    Taskerville.Supervisor.start_link()
  end

  @doc """
  Schedule a recurring task where
  - `cron_str` - a cron string readable by the Crontab module.
    See https://hexdocs.pm/crontab/basic-usage.html#parse-cron-expressions for more info
  - `name` - a name to refrence the task by
  - `max_concurrent` - maximum number of current versions of this task that can be running
    0 = infinite
  - task - either an anonomous function with arguments {func, args} or {module, function, args}

  ## Examples
    iex> Taskerville.schedule("* * * * *", "atom_tester", 0, {Kernel, :is_atom, [:frank]})
    :ok
    iex> Taskerville.schedule("*/5 * * * *", "IO_putter", 0, {fn -> IO.puts("test 1") end, []})
    :ok
  """
  def schedule(cron_str, name, max_concurrent, task) do
    Taskerville.Scheduler.Server.schedule_task(cron_str, name, max_concurrent, task)
    :ok
  end

  @doc """
  Returns a list of all scheduled items.

  ## Examples
    iex> Taskerville.start()
    iex> Taskerville.schedule("* * * * *", "atom_tester", 0, {Kernel, :is_atom, [:frank]})
    iex> Taskerville.schedule("*/5 * * * *", "IO_putter", 3, {fn -> IO.puts("test 1") end, []})
    iex> scheduled_items = Taskerville.get_scheduled_items()
    iex> io_putter_task = Enum.at(scheduled_items, 0)
    iex> atom_tester_task =  Enum.at(scheduled_items, 1)
    iex> io_putter_task.task_name == "IO_putter"
    true
    iex> io_putter_task.max_concurrent == 3
    true
    iex> atom_tester_task.task_name == "atom_tester"
    true
  """
  def get_scheduled_items do
    Taskerville.Scheduler.Server.get_scheduled_items()
  end

  @doc """
  Returns a map of task names and currently running tasks

  ex return:
  %{
    "IO_putter" => [#PID<0.215.0>],
    "frequent_task" => [#PID<0.216.0>, #PID<0.211.0>],
    "task_2" => []
  }
  """
  def get_running_tasks do
    Taskerville.TaskRunner.Manager.get_running_tasks()
  end
end
