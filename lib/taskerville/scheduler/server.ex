defmodule Taskerville.Scheduler.Server do

  @name __MODULE__

  require Logger

  alias Taskerville.TaskRunner

  use GenServer

  defmodule ScheduleItem do
    @enforce_keys [:interval, :task_name, :func]
    defstruct [:interval, :task_name, :func, max_concurrent: 0]
  end

  # Client Functions
  def start_link(_args) do
    Logger.info("Starting the Scheduler Server...")
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def schedule_task(interval, task_name, max_concurrent, func) do
    GenServer.cast @name, {:schedule, interval, task_name, max_concurrent, func}
  end

  def get_scheduled_items do
    GenServer.call @name, :get_scheduled_items
  end

  # Server Functions

  def init(state) do
    schedule_next_evaluation()
    {:ok, state}
  end

  def handle_cast({:schedule, interval, task_name, max_concurrent, func}, state) do
    schedule_item = %ScheduleItem{interval: interval, task_name: task_name, func: func, max_concurrent: max_concurrent}
    state = [schedule_item | state]
    {:noreply, state}
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
    current_time = DateTime.utc_now() |> DateTime.to_unix()
    state
      |> Enum.each(&(can_run_task(&1, current_time)))
  end

  defp can_run_task(schedule_item, current_time) do
    interval = schedule_item.interval
    current_time = div(current_time, 10) * 10 # ensure seconds end in 0
    case interval do
      :minute ->
        run_task(schedule_item)
      :minutes_5 ->
        if rem(current_time, 5 * 60) == 0, do: run_task(schedule_item)
      :minutes_10 ->
        if rem(current_time, 10 * 60) == 0, do: run_task(schedule_item)
      _ ->
        Logger.warn("an invalid interval was submitted: #{interval}")
    end

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
