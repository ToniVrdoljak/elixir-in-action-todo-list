defmodule Todo.Cache do
  use GenServer

  @impl GenServer
  def init(_) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      :error ->
        {:ok, todo_server_pid} = Todo.Server.start()
        new_todo_servers = Map.put(todo_servers, todo_list_name, todo_server_pid)
        {:reply, todo_server_pid, new_todo_servers}

      {:ok, todo_server_pid} ->
        {:reply, todo_server_pid, todo_servers}
    end
  end

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:server_process, todo_list_name})
  end
end
