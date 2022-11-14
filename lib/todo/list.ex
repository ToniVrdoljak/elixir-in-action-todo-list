defmodule Todo.List do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries, %Todo.List{}, &add_entry(&2, &1))
  end

  def add_entry(%Todo.List{auto_id: auto_id, entries: entries}, entry) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = Map.put(entries, auto_id, entry)

    %Todo.List{auto_id: auto_id + 1, entries: new_entries}
  end

  def entries(%Todo.List{entries: entries}, date) do
    entries
    |> Stream.filter(fn {_, entry} ->
      entry.date == date
    end)
    |> Enum.map(fn {_, entry} ->
      entry
    end)
  end

  def update_entry(%Todo.List{entries: entries} = todo_list, id, updater_fun) do
    case Map.fetch(entries, id) do
      :error ->
        todo_list

      {:ok, entry} ->
        new_entry = %{id: ^id} = updater_fun.(entry)
        new_entries = %{entries | id => new_entry}
        %Todo.List{todo_list | entries: new_entries}
    end
  end

  def update_entry(%Todo.List{} = todo_list, %{id: id, date: _, title: _} = new_entry) do
    update_entry(todo_list, id, fn _ -> new_entry end)
  end

  def delete_entry(%Todo.List{entries: entries} = todo_list, id) do
    %Todo.List{todo_list | entries: Map.delete(entries, id)}
  end
end
