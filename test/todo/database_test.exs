defmodule Todo.DatabaseTest do
  use ExUnit.Case
  doctest Todo.Database

  setup do
    on_exit(fn ->
      File.rm_rf("./persist")
    end)
  end

  test "Storing and reading from disk succeeds" do
    todo_list =
      Todo.List.new([
        %{date: {2013, 12, 19}, title: "TODO1"},
        %{date: {2013, 12, 19}, title: "TODO2"}
      ])

    Todo.Database.start("./persist")
    Todo.Database.store("some_todo_list", todo_list)

    # Since storing to and reading from disk is now done in a separete process these operations are not sequential. It can happen that :get opertaion is exectued before the data is actually stored to disk. That is why we use sleep to give the :store operation time to actually finish before the :get operation is executed.
    :timer.sleep(5)

    persisted_todo_list = Todo.Database.get("some_todo_list")

    assert persisted_todo_list == todo_list
  end
end
