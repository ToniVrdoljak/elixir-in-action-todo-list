defmodule Todo.ListTest do
  use ExUnit.Case
  doctest Todo.List

  test "New Todo.List is empty" do
    todo_list = Todo.List.new()

    result_list = Todo.List.entries(todo_list, {2013, 12, 19})
    assert result_list == []
  end

  test "Initializing Todo.List with entries" do
    todo_list =
      Todo.List.new([
        %{date: {2013, 12, 19}, title: "TODO1"},
        %{date: {2013, 12, 19}, title: "TODO2"}
      ])

    result_list = Todo.List.entries(todo_list, {2013, 12, 19})

    assert result_list == [
             %{id: 1, date: {2013, 12, 19}, title: "TODO1"},
             %{id: 2, date: {2013, 12, 19}, title: "TODO2"}
           ]
  end

  test "Adding to empty date and reading succeeds" do
    todo_list =
      Todo.List.new()
      |> Todo.List.add_entry(%{date: {2013, 12, 19}, title: "TODO1"})

    result_list = Todo.List.entries(todo_list, {2013, 12, 19})
    assert result_list == [%{id: 1, date: {2013, 12, 19}, title: "TODO1"}]
  end

  test "Adding to existing date and reading succeeds" do
    todo_list =
      Todo.List.new()
      |> Todo.List.add_entry(%{date: {2013, 12, 19}, title: "TODO1"})
      |> Todo.List.add_entry(%{date: {2013, 12, 19}, title: "TODO2"})

    result_list = Todo.List.entries(todo_list, {2013, 12, 19})

    assert result_list == [
             %{id: 1, date: {2013, 12, 19}, title: "TODO1"},
             %{id: 2, date: {2013, 12, 19}, title: "TODO2"}
           ]
  end

  test "Reading when there are multiple dates succeeds" do
    todo_list =
      Todo.List.new([
        %{date: {2013, 12, 19}, title: "TODO1"},
        %{date: {2013, 12, 20}, title: "TODO2"}
      ])

    result_list = Todo.List.entries(todo_list, {2013, 12, 19})
    assert result_list == [%{id: 1, date: {2013, 12, 19}, title: "TODO1"}]

    result_list = Todo.List.entries(todo_list, {2013, 12, 20})
    assert result_list == [%{id: 2, date: {2013, 12, 20}, title: "TODO2"}]
  end

  test "Updating entry succeeds" do
    todo_list =
      Todo.List.new()
      |> Todo.List.add_entry(%{date: {2013, 12, 19}, title: "TODO1"})

    todo_list =
      Todo.List.update_entry(todo_list, 1, fn _ ->
        %{id: 1, date: {2013, 12, 20}, title: "TODO2"}
      end)

    result_list = Todo.List.entries(todo_list, {2013, 12, 20})
    assert result_list == [%{id: 1, date: {2013, 12, 20}, title: "TODO2"}]
  end

  test "Updating entry with changed id fails" do
    todo_list =
      Todo.List.new()
      |> Todo.List.add_entry(%{date: {2013, 12, 19}, title: "TODO1"})

    assert_raise MatchError, fn ->
      Todo.List.update_entry(todo_list, 1, fn _ ->
        %{id: 2, date: {2013, 12, 20}, title: "TODO2"}
      end)
    end
  end

  test "Updating entry with alternative interface succeeds" do
    todo_list =
      Todo.List.new()
      |> Todo.List.add_entry(%{date: {2013, 12, 19}, title: "TODO1"})

    todo_list = Todo.List.update_entry(todo_list, %{id: 1, date: {2013, 12, 20}, title: "TODO2"})

    result_list = Todo.List.entries(todo_list, {2013, 12, 20})
    assert result_list == [%{id: 1, date: {2013, 12, 20}, title: "TODO2"}]
  end

  test "Updating entry with alternative interface with malformed entry fails" do
    todo_list =
      Todo.List.new()
      |> Todo.List.add_entry(%{date: {2013, 12, 19}, title: "TODO1"})

    assert_raise FunctionClauseError, fn ->
      Todo.List.update_entry(todo_list, %{id: 1, title: "TODO2"})
    end
  end

  test "Deleting entry succeeds" do
    todo_list =
      Todo.List.new()
      |> Todo.List.add_entry(%{date: {2013, 12, 19}, title: "TODO1"})

    todo_list = Todo.List.delete_entry(todo_list, 1)

    result_list = Todo.List.entries(todo_list, {2013, 12, 19})
    assert result_list == []
  end
end
