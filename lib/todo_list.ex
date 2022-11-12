defmodule TodoList do
  def new, do: %{}

  def add_entry(todo_list, entry) do
    Map.update(todo_list, entry.date, [entry], &[entry | &1])
  end

  def entries(todo_list, date) do
    Map.get(todo_list, date, [])
  end
end
