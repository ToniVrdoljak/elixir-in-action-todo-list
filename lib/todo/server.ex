defmodule Todo.Server do
  use GenServer

  @impl GenServer
  def init({name, entries}) do
    case Todo.Database.start("./persist") do
      {:ok, _} -> IO.puts("Started database")
      {:error, {:already_started, _}} -> IO.puts("Database was already started")
    end

    todo_list =
      case entries do
        [] ->
          send(self(), :real_init)
          nil

        _ ->
          new_todo_list = Todo.List.new(entries)
          Todo.Database.store(name, new_todo_list)
          new_todo_list
      end

    {:ok, {name, todo_list}}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, {name, todo_list}) do
    new_todo_list = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(name, new_todo_list)
    {:noreply, {name, new_todo_list}}
  end

  @impl GenServer
  def handle_cast({:update_entry, id, updater_fun}, {name, todo_list}) do
    new_todo_list = Todo.List.update_entry(todo_list, id, updater_fun)
    Todo.Database.store(name, new_todo_list)
    {:noreply, {name, new_todo_list}}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry}, {name, todo_list}) do
    new_todo_list = Todo.List.update_entry(todo_list, entry)
    Todo.Database.store(name, new_todo_list)
    {:noreply, {name, new_todo_list}}
  end

  @impl GenServer
  def handle_cast({:delete_entry, id}, {name, todo_list}) do
    new_todo_list = Todo.List.delete_entry(todo_list, id)
    Todo.Database.store(name, new_todo_list)
    {:noreply, {name, new_todo_list}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {name, todo_list}}
  end

  @impl GenServer
  def handle_info(:real_init, {name, nil}) do
    # this is where the initialization from disk is really performed
    todo_list = Todo.Database.get(name) || Todo.List.new()
    {:noreply, {name, todo_list}}
  end

  @impl GenServer
  def handle_info(_, state), do: {:noreply, state}

  def start(name, entries \\ []) do
    GenServer.start(__MODULE__, {name, entries})
  end

  def add_entry(pid, %{date: _, title: _} = entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end

  def update_entry(pid, id, updater_fun) do
    GenServer.cast(pid, {:update_entry, id, updater_fun})
  end

  def update_entry(pid, %{id: _, date: _, title: _} = entry) do
    GenServer.cast(pid, {:update_entry, entry})
  end

  def delete_entry(pid, id) do
    GenServer.cast(pid, {:delete_entry, id})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end
end
