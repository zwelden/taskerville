defmodule Taskerville.TaskRunner.RunSupervisor do

  alias Taskerville.TaskRunner.Runner

  use DynamicSupervisor

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_child(func) do
    spec = {Runner, func}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
