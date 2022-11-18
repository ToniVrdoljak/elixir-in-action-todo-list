defmodule Todo.ServerTest do
  use ExUnit.Case
  doctest Todo.Server

  setup do
    on_exit(fn ->
      # Because store operation is asynchronous we need this sleep so we can be sure that the previous store is completed before removing the file
      :timer.sleep(5)
      File.rm_rf("./persist")
    end)
  end

  test "New Todo.List is empty" do
    File.rm_rf("./persist")
    {:ok, pid} = Todo.Server.start("some_todo_list")

    result_list = Todo.Server.entries(pid, {2013, 12, 19})
    assert result_list == []
  end

  test "Initializing Todo.List with entries" do
    File.rm_rf("./persist")

    {:ok, pid} =
      Todo.Server.start("some_todo_list", [
        %{date: {2013, 12, 19}, title: "TODO1"},
        %{date: {2013, 12, 19}, title: "TODO2"}
      ])

    result_list = Todo.Server.entries(pid, {2013, 12, 19})

    assert result_list == [
             %{id: 1, date: {2013, 12, 19}, title: "TODO1"},
             %{id: 2, date: {2013, 12, 19}, title: "TODO2"}
           ]
  end

  test "Adding to empty date and reading succeeds" do
    File.rm_rf("./persist")
    {:ok, pid} = Todo.Server.start("some_todo_list")
    Todo.Server.add_entry(pid, %{date: {2013, 12, 19}, title: "TODO1"})

    result_list = Todo.Server.entries(pid, {2013, 12, 19})
    assert result_list == [%{id: 1, date: {2013, 12, 19}, title: "TODO1"}]
  end

  test "Adding to existing date and reading succeeds" do
    File.rm_rf("./persist")
    {:ok, pid} = Todo.Server.start("some_todo_list", [%{date: {2013, 12, 19}, title: "TODO1"}])
    Todo.Server.add_entry(pid, %{date: {2013, 12, 19}, title: "TODO2"})

    result_list = Todo.Server.entries(pid, {2013, 12, 19})

    assert result_list == [
             %{id: 1, date: {2013, 12, 19}, title: "TODO1"},
             %{id: 2, date: {2013, 12, 19}, title: "TODO2"}
           ]
  end

  test "Reading when there are multiple dates succeeds" do
    File.rm_rf("./persist")

    {:ok, pid} =
      Todo.Server.start("some_todo_list", [
        %{date: {2013, 12, 19}, title: "TODO1"},
        %{date: {2013, 12, 20}, title: "TODO2"}
      ])

    result_list = Todo.Server.entries(pid, {2013, 12, 19})
    assert result_list == [%{id: 1, date: {2013, 12, 19}, title: "TODO1"}]

    result_list = Todo.Server.entries(pid, {2013, 12, 20})
    assert result_list == [%{id: 2, date: {2013, 12, 20}, title: "TODO2"}]
  end

  test "Updating entry succeeds" do
    File.rm_rf("./persist")
    {:ok, pid} = Todo.Server.start("some_todo_list", [%{date: {2013, 12, 19}, title: "TODO1"}])

    Todo.Server.update_entry(pid, 1, fn _ ->
      %{id: 1, date: {2013, 12, 20}, title: "TODO2"}
    end)

    result_list = Todo.Server.entries(pid, {2013, 12, 20})
    assert result_list == [%{id: 1, date: {2013, 12, 20}, title: "TODO2"}]
  end

  test "Updating entry with alternative interface succeeds" do
    File.rm_rf("./persist")
    {:ok, pid} = Todo.Server.start("some_todo_list", [%{date: {2013, 12, 19}, title: "TODO1"}])

    Todo.Server.update_entry(pid, %{id: 1, date: {2013, 12, 20}, title: "TODO2"})

    result_list = Todo.Server.entries(pid, {2013, 12, 20})
    assert result_list == [%{id: 1, date: {2013, 12, 20}, title: "TODO2"}]
  end

  test "Deleting entry succeeds" do
    File.rm_rf("./persist")
    {:ok, pid} = Todo.Server.start("some_todo_list", [%{date: {2013, 12, 19}, title: "TODO1"}])

    Todo.Server.delete_entry(pid, 1)

    result_list = Todo.Server.entries(pid, {2013, 12, 19})
    assert result_list == []

    File.rm_rf("./persist")
  end

  test "Todo.Server reads data stored to disk" do
    todo_list =
      Todo.List.new([
        %{id: 1, date: {2013, 12, 19}, title: "TODO1"},
        %{id: 2, date: {2013, 12, 19}, title: "TODO2"}
      ])

    Todo.Database.start("./persist")
    Todo.Database.store("some_todo_list", todo_list)

    # Since storing to and reading from disk is now done in a separete process these operations are not sequential. It can happen that :get opertaion is exectued before the data is actually stored to disk. That is why we use sleep to give the :store operation time to actually finish before the :get operation is executed.
    :timer.sleep(5)

    {:ok, pid} = Todo.Server.start("some_todo_list")
    persisted_todo_list_entry = Todo.Server.entries(pid, {2013, 12, 19})

    assert persisted_todo_list_entry == Todo.List.entries(todo_list, {2013, 12, 19})
  end
end
