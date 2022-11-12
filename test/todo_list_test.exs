defmodule TodoListTest do
  use ExUnit.Case
  doctest TodoList

  test "New TodoList is empty" do
    todo_list = TodoList.new()

    result_list = TodoList.entries(todo_list, {2013, 12, 19})
    assert result_list == []
  end

  test "Adding to empty date and reading" do
    todo_list =
      TodoList.new()
      |> TodoList.add_entry(%{date: {2013, 12, 19}, title: "TODO1"})

    result_list = TodoList.entries(todo_list, {2013, 12, 19})
    assert result_list == [%{date: {2013, 12, 19}, title: "TODO1"}]
  end

  test "Adding to existing date and reading" do
    todo_list =
      TodoList.new()
      |> TodoList.add_entry(%{date: {2013, 12, 19}, title: "TODO1"})
      |> TodoList.add_entry(%{date: {2013, 12, 19}, title: "TODO2"})

    result_list = TodoList.entries(todo_list, {2013, 12, 19})

    assert result_list == [
             %{date: {2013, 12, 19}, title: "TODO2"},
             %{date: {2013, 12, 19}, title: "TODO1"}
           ]
  end
end
