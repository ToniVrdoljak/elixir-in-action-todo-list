defmodule Todo.Server do
  use GenServer

  @impl GenServer
  def init(entries) do
    {:ok, Todo.List.new(entries)}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, todo_list) do
    {:noreply, Todo.List.add_entry(todo_list, entry)}
  end

  @impl GenServer
  def handle_cast({:update_entry, id, updater_fun}, todo_list) do
    {:noreply, Todo.List.update_entry(todo_list, id, updater_fun)}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry}, todo_list) do
    {:noreply, Todo.List.update_entry(todo_list, entry)}
  end

  @impl GenServer
  def handle_cast({:delete_entry, id}, todo_list) do
    {:noreply, Todo.List.delete_entry(todo_list, id)}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, todo_list) do
    {:reply, Todo.List.entries(todo_list, date), todo_list}
  end

  @impl GenServer
  def handle_info(:cleanup, state) do
    # this method is just an example how to use handle info
    IO.puts("Perfroming cleanup...")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(_, state), do: {:noreply, state}

  def start(entries \\ []) do
    GenServer.start(Todo.Server, entries)
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
