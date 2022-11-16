defmodule Todo.CacheTest do
  use ExUnit.Case
  doctest Todo.Cache

  setup do
    on_exit(fn ->
      File.rm_rf("./persist")
    end)
  end

  test "Todo.Cache creates different todo lists (PIDs) for diferent names" do
    {:ok, cache_pid} = Todo.Cache.start()

    pid1 = Todo.Cache.server_process(cache_pid, :name1)
    pid2 = Todo.Cache.server_process(cache_pid, :name2)

    assert pid1 != pid2
  end

  test "Todo.Cache reuses the same todo list (PID) for the same name" do
    {:ok, cache_pid} = Todo.Cache.start()

    pid1 = Todo.Cache.server_process(cache_pid, :name)
    pid2 = Todo.Cache.server_process(cache_pid, :name)

    assert pid1 == pid2
  end

  test "Todo.Server reads data stored to disk" do
    todo_list =
      Todo.List.new([
        %{id: 1, date: {2013, 12, 19}, title: "TODO1"},
        %{id: 2, date: {2013, 12, 19}, title: "TODO2"}
      ])

    Todo.Database.start("./persist")
    Todo.Database.store("some_todo_list", todo_list)

    {:ok, pid} = Todo.Cache.start()
    todo_pid = Todo.Cache.server_process(pid, "some_todo_list")
    persisted_todo_list_entry = Todo.Server.entries(todo_pid, {2013, 12, 19})

    assert persisted_todo_list_entry == Todo.List.entries(todo_list, {2013, 12, 19})
  end
end
