defmodule Taskerville do
  @moduledoc """
  Documentation for `Taskerville`.
  """

  require Logger

  def start do
    Logger.info("Starting Taskerville...")
    Taskerville.Supervisor.start_link()
  end

  def schedule(chron_str, name, func) do
    Taskerville.Scheduler.Server.schedule_task(chron_str, name, func)
    :ok
  end

  def get_scheduled_items do
    Taskerville.Scheduler.Server.get_scheduled_items()
  end
end
