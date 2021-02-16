# Taskerville
A simple cron like task scheduler in Elixir.

## Installation

Taskerville is avaliable on [hex.pm](https://hex.pm/packages/taskerville).

The package can be installed by adding `taskerville` to your list of 
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:taskerville, "~> 0.0.1"}
  ]
end
```

Documentation can be found at [https://hexdocs.pm/taskerville](https://hexdocs.pm/taskerville).

## Usage 

#### Start the task manager 
```elixir
iex> Taskerville.start()
```

#### Schedule a task 
Tasks can be either a simple anomous function or a tuple of {Module, Function, \[args\]}

```elixir 
# A task that runs every minute, named "atom_tester", with any number of 
# concurrent versions of this task running, where the task is Kernel.is_atom(:frank)
Taskerville.schedule("* * * * *", "atom_tester", 0, {Kernel, :is_atom, [:frank]})

# A task that runs every 5 minutes, named "IO_putter", with only 3 concurrent 
# versions allowed, that runs an anonymous function with no arguments.
Taskerville.schedule("*/5 * * * *", "IO_putter", 3, {fn -> IO.puts("test 1") end, []})
```

