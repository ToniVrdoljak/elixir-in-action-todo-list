defmodule Todo.ServerTest do
  use ExUnit.Case
  doctest Todo.Server

  test "New Todo.List is empty" do
    {:ok, pid} = Todo.Server.start()

    result_list = Todo.Server.entries(pid, {2013, 12, 19})
    assert result_list == []
  end

  test "Initializing Todo.List with entries" do
    {:ok, pid} =
      Todo.Server.start([
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
    {:ok, pid} = Todo.Server.start()
    Todo.Server.add_entry(pid, %{date: {2013, 12, 19}, title: "TODO1"})

    result_list = Todo.Server.entries(pid, {2013, 12, 19})
    assert result_list == [%{id: 1, date: {2013, 12, 19}, title: "TODO1"}]
  end

  test "Adding to existing date and reading succeeds" do
    {:ok, pid} = Todo.Server.start([%{date: {2013, 12, 19}, title: "TODO1"}])
    Todo.Server.add_entry(pid, %{date: {2013, 12, 19}, title: "TODO2"})

    result_list = Todo.Server.entries(pid, {2013, 12, 19})

    assert result_list == [
             %{id: 1, date: {2013, 12, 19}, title: "TODO1"},
             %{id: 2, date: {2013, 12, 19}, title: "TODO2"}
           ]
  end

  test "Reading when there are multiple dates succeeds" do
    {:ok, pid} =
      Todo.Server.start([
        %{date: {2013, 12, 19}, title: "TODO1"},
        %{date: {2013, 12, 20}, title: "TODO2"}
      ])

    result_list = Todo.Server.entries(pid, {2013, 12, 19})
    assert result_list == [%{id: 1, date: {2013, 12, 19}, title: "TODO1"}]

    result_list = Todo.Server.entries(pid, {2013, 12, 20})
    assert result_list == [%{id: 2, date: {2013, 12, 20}, title: "TODO2"}]
  end

  test "Updating entry succeeds" do
    {:ok, pid} = Todo.Server.start([%{date: {2013, 12, 19}, title: "TODO1"}])

    Todo.Server.update_entry(pid, 1, fn _ ->
      %{id: 1, date: {2013, 12, 20}, title: "TODO2"}
    end)

    result_list = Todo.Server.entries(pid, {2013, 12, 20})
    assert result_list == [%{id: 1, date: {2013, 12, 20}, title: "TODO2"}]
  end

  test "Updating entry with alternative interface succeeds" do
    {:ok, pid} = Todo.Server.start([%{date: {2013, 12, 19}, title: "TODO1"}])

    Todo.Server.update_entry(pid, %{id: 1, date: {2013, 12, 20}, title: "TODO2"})

    result_list = Todo.Server.entries(pid, {2013, 12, 20})
    assert result_list == [%{id: 1, date: {2013, 12, 20}, title: "TODO2"}]
  end

  test "Deleting entry succeeds" do
    {:ok, pid} = Todo.Server.start([%{date: {2013, 12, 19}, title: "TODO1"}])

    Todo.Server.delete_entry(pid, 1)

    result_list = Todo.Server.entries(pid, {2013, 12, 19})
    assert result_list == []
  end
end
