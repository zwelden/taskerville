defmodule Taskerville do
  @moduledoc """
  Documentation for `Taskerville`.
  """

  require Logger

  def start do
    Logger.info("Starting Taskerville...")
    Taskerville.Supervisor.start_link()
  end

  def schedule(chron_str, name, max_concurrent, func) do
    Taskerville.Scheduler.Server.schedule_task(chron_str, name, max_concurrent, func)
    :ok
  end

  def get_scheduled_items do
    Taskerville.Scheduler.Server.get_scheduled_items()
  end

  def get_running_tasks do
    Taskerville.TaskRunner.Manager.get_running_tasks()
  end
end
