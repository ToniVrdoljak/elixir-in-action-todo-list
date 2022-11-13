defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new, do: %TodoList{}

  def add_entry(%TodoList{auto_id: auto_id, entries: entries}, entry) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = Map.put(entries, auto_id, entry)

    %TodoList{auto_id: auto_id + 1, entries: new_entries}
  end

  def entries(%TodoList{entries: entries}, date) do
    entries
    |> Stream.filter(fn {_, entry} ->
      entry.date == date
    end)
    |> Enum.map(fn {_, entry} ->
      entry
    end)
  end

  def update_entry(%TodoList{entries: entries} = todo_list, id, updater_fun) do
    case Map.fetch(entries, id) do
      :error ->
        todo_list

      {:ok, entry} ->
        new_entry = %{id: ^id} = updater_fun.(entry)
        new_entries = %{entries | id => new_entry}
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def update_entry(%TodoList{} = todo_list, %{id: id, date: _, title: _} = new_entry) do
    update_entry(todo_list, id, fn _ -> new_entry end)
  end

  def delete_entry(%TodoList{entries: entries} = todo_list, id) do
    %TodoList{todo_list | entries: Map.delete(entries, id)}
  end
end
