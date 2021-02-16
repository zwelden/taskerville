defmodule Taskerville.Scheduler.Server do

  @name __MODULE__

  require Logger

  alias Taskerville.TaskRunner
  alias Crontab.CronExpression.Parser, as: CronParser
  alias Crontab.DateChecker, as: CronDate

  use GenServer


  @doc """
  ex:
  %Taskerville.Scheduler.Server.ScheduleItem{
    crontab: ~e[* * * * * *],
    func: {Kernel, :is_atom, [:frank]},
    max_concurrent: 4,
    task_name: "atom_tester"
  }
  """
  defmodule ScheduleItem do
    @enforce_keys [:crontab, :task_name, :func]
    defstruct [:crontab, :task_name, :func, max_concurrent: 0]
  end

  # Client Functions

  def start_link(_args) do
    Logger.info("Starting the Scheduler Server...")
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def schedule_task(chron_str, task_name, max_concurrent, func) do
    GenServer.cast @name, {:schedule, chron_str, task_name, max_concurrent, func}
  end

  def get_scheduled_items do
    GenServer.call @name, :get_scheduled_items
  end

  # Server Functions

  def init(state) do
    schedule_next_evaluation()
    {:ok, state}
  end

  def handle_cast({:schedule, chron_str, task_name, max_concurrent, func}, state) do
    case CronParser.parse(chron_str) do
      {:ok, crontab} ->
        schedule_item = %ScheduleItem{crontab: crontab, task_name: task_name, func: func, max_concurrent: max_concurrent}
        {:noreply, [schedule_item | state]}
      {:error, error_reason} ->
        Logger.warn("Unable to schedule item. task name: #{task_name}, reason: #{error_reason}")
        {:noreply, state}
      _ ->
        Logger.warn("Unable to schedule item for an unknown reason. task name: #{task_name}")
        {:noreply, state}
    end
  end

  def handle_call(:get_scheduled_items, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:evaluate_schedule, state) do
    evaluate_tasks_to_run(state)
    schedule_next_evaluation()
    {:noreply, state}
  end

  def handle_info(undefined, state) do
    Logger.warn "Got unexpected handle_info: #{inspect undefined}"
    {:noreply, state}
  end

  defp evaluate_tasks_to_run(state) do
    current_time = NaiveDateTime.local_now()
    state
      |> Enum.each(&(can_run_task(&1, current_time)))
  end

  defp can_run_task(schedule_item, current_time) do
    crontab = schedule_item.crontab

    if CronDate.matches_date?(crontab, current_time) == true, do: run_task(schedule_item)
  end

  defp run_task(schedule_item) do
    TaskRunner.Manager.run(schedule_item.task_name, schedule_item.max_concurrent, schedule_item.func)
  end

  defp schedule_next_evaluation do
    sec_offset = DateTime.utc_now()
      |>  DateTime.to_unix()
      |> rem(60)
      |> (&(60 - &1)).()

    Process.send_after(self(), :evaluate_schedule, :timer.seconds(sec_offset))
  end
end
