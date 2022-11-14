defmodule Todo.CacheTest do
  use ExUnit.Case
  doctest Todo.Cache

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
end
