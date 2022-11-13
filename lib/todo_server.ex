defmodule TodoServer do
  use GenServer

  def init(entries) do
    {:ok, TodoList.new(entries)}
  end

  def handle_cast({:add_entry, entry}, todo_list) do
    {:noreply, TodoList.add_entry(todo_list, entry)}
  end

  def handle_cast({:update_entry, id, updater_fun}, todo_list) do
    {:noreply, TodoList.update_entry(todo_list, id, updater_fun)}
  end

  def handle_cast({:update_entry, entry}, todo_list) do
    {:noreply, TodoList.update_entry(todo_list, entry)}
  end

  def handle_cast({:delete_entry, id}, todo_list) do
    {:noreply, TodoList.delete_entry(todo_list, id)}
  end

  def handle_call({:entries, date}, _, todo_list) do
    {:reply, TodoList.entries(todo_list, date), todo_list}
  end

  def handle_info(:cleanup, state) do
    # this method is just an example how to use handle info
    IO.puts("Perfroming cleanup...")
    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}

  def start(entries \\ []) do
    GenServer.start(TodoServer, entries)
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
