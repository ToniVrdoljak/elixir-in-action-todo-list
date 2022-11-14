defmodule TodoServerTest do
  use ExUnit.Case
  doctest TodoServer

  test "New TodoList is empty" do
    {:ok, pid} = TodoServer.start()

    result_list = TodoServer.entries(pid, {2013, 12, 19})
    assert result_list == []
  end

  test "Initializing TodoList with entries" do
    {:ok, pid} =
      TodoServer.start([
        %{date: {2013, 12, 19}, title: "TODO1"},
        %{date: {2013, 12, 19}, title: "TODO2"}
      ])

    result_list = TodoServer.entries(pid, {2013, 12, 19})

    assert result_list == [
             %{id: 1, date: {2013, 12, 19}, title: "TODO1"},
             %{id: 2, date: {2013, 12, 19}, title: "TODO2"}
           ]
  end

  test "Adding to empty date and reading succeeds" do
    {:ok, pid} = TodoServer.start()
    TodoServer.add_entry(pid, %{date: {2013, 12, 19}, title: "TODO1"})

    result_list = TodoServer.entries(pid, {2013, 12, 19})
    assert result_list == [%{id: 1, date: {2013, 12, 19}, title: "TODO1"}]
  end

  test "Adding to existing date and reading succeeds" do
    {:ok, pid} = TodoServer.start([%{date: {2013, 12, 19}, title: "TODO1"}])
    TodoServer.add_entry(pid, %{date: {2013, 12, 19}, title: "TODO2"})

    result_list = TodoServer.entries(pid, {2013, 12, 19})

    assert result_list == [
             %{id: 1, date: {2013, 12, 19}, title: "TODO1"},
             %{id: 2, date: {2013, 12, 19}, title: "TODO2"}
           ]
  end

  test "Updating entry succeeds" do
    {:ok, pid} = TodoServer.start([%{date: {2013, 12, 19}, title: "TODO1"}])

    TodoServer.update_entry(pid, 1, fn _ ->
      %{id: 1, date: {2013, 12, 20}, title: "TODO2"}
    end)

    result_list = TodoServer.entries(pid, {2013, 12, 20})
    assert result_list == [%{id: 1, date: {2013, 12, 20}, title: "TODO2"}]
  end

  test "Updating entry with alternative interface succeeds" do
    {:ok, pid} = TodoServer.start([%{date: {2013, 12, 19}, title: "TODO1"}])

    TodoServer.update_entry(pid, %{id: 1, date: {2013, 12, 20}, title: "TODO2"})

    result_list = TodoServer.entries(pid, {2013, 12, 20})
    assert result_list == [%{id: 1, date: {2013, 12, 20}, title: "TODO2"}]
  end

  test "Deleting entry succeeds" do
    {:ok, pid} = TodoServer.start([%{date: {2013, 12, 19}, title: "TODO1"}])

    TodoServer.delete_entry(pid, 1)

    result_list = TodoServer.entries(pid, {2013, 12, 19})
    assert result_list == []
  end
end
