defmodule TodoListTest do
  use ExUnit.Case
  doctest TodoList

  test "New TodoList is empty" do
    todo_list = TodoList.new()

    result_list = TodoList.entries(todo_list, {2013, 12, 19})
    assert result_list == []
  end

  test "Initializing TodoList with entries" do
    todo_list =
      TodoList.new([
        %{date: {2013, 12, 19}, title: "TODO1"},
        %{date: {2013, 12, 19}, title: "TODO2"}
      ])

    result_list = TodoList.entries(todo_list, {2013, 12, 19})

    assert result_list == [
             %{id: 1, date: {2013, 12, 19}, title: "TODO1"},
             %{id: 2, date: {2013, 12, 19}, title: "TODO2"}
           ]
  end

  test "Adding to empty date and reading succeeds" do
    todo_list =
      TodoList.new()
      |> TodoList.add_entry(%{date: {2013, 12, 19}, title: "TODO1"})

    result_list = TodoList.entries(todo_list, {2013, 12, 19})
    assert result_list == [%{id: 1, date: {2013, 12, 19}, title: "TODO1"}]
  end

  test "Adding to existing date and reading succeeds" do
    todo_list =
      TodoList.new()
      |> TodoList.add_entry(%{date: {2013, 12, 19}, title: "TODO1"})
      |> TodoList.add_entry(%{date: {2013, 12, 19}, title: "TODO2"})

    result_list = TodoList.entries(todo_list, {2013, 12, 19})

    assert result_list == [
             %{id: 1, date: {2013, 12, 19}, title: "TODO1"},
             %{id: 2, date: {2013, 12, 19}, title: "TODO2"}
           ]
  end

  test "Updating entry succeeds" do
    todo_list =
      TodoList.new()
      |> TodoList.add_entry(%{date: {2013, 12, 19}, title: "TODO1"})

    todo_list =
      TodoList.update_entry(todo_list, 1, fn _ ->
        %{id: 1, date: {2013, 12, 20}, title: "TODO2"}
      end)

    result_list = TodoList.entries(todo_list, {2013, 12, 20})
    assert result_list == [%{id: 1, date: {2013, 12, 20}, title: "TODO2"}]
  end

  test "Updating entry with changed id fails" do
    todo_list =
      TodoList.new()
      |> TodoList.add_entry(%{date: {2013, 12, 19}, title: "TODO1"})

    assert_raise MatchError, fn ->
      TodoList.update_entry(todo_list, 1, fn _ ->
        %{id: 2, date: {2013, 12, 20}, title: "TODO2"}
      end)
    end
  end

  test "Updating entry with alternative interface succeeds" do
    todo_list =
      TodoList.new()
      |> TodoList.add_entry(%{date: {2013, 12, 19}, title: "TODO1"})

    todo_list = TodoList.update_entry(todo_list, %{id: 1, date: {2013, 12, 20}, title: "TODO2"})

    result_list = TodoList.entries(todo_list, {2013, 12, 20})
    assert result_list == [%{id: 1, date: {2013, 12, 20}, title: "TODO2"}]
  end

  test "Updating entry with alternative interface with malformed entry fails" do
    todo_list =
      TodoList.new()
      |> TodoList.add_entry(%{date: {2013, 12, 19}, title: "TODO1"})

    assert_raise FunctionClauseError, fn ->
      TodoList.update_entry(todo_list, %{id: 1, title: "TODO2"})
    end
  end

  test "Deleting entry succeeds" do
    todo_list =
      TodoList.new()
      |> TodoList.add_entry(%{date: {2013, 12, 19}, title: "TODO1"})

    todo_list = TodoList.delete_entry(todo_list, 1)

    result_list = TodoList.entries(todo_list, {2013, 12, 19})
    assert result_list == []
  end
end
