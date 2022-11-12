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
      |> TodoList.add_entry({2013, 12, 19}, "TODO1")

    result_list = TodoList.entries(todo_list, {2013, 12, 19})
    assert result_list == ["TODO1"]
  end

  test "Adding to existing date and reading" do
    todo_list =
      TodoList.new()
      |> TodoList.add_entry({2013, 12, 19}, "TODO1")
      |> TodoList.add_entry({2013, 12, 19}, "TODO2")

    result_list = TodoList.entries(todo_list, {2013, 12, 19})
    assert result_list == ["TODO2", "TODO1"]
  end
end
