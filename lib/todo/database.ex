defmodule Todo.Database do
  use GenServer

  @impl GenServer
  def init(db_folder) do
    {:ok, {db_folder, start_workers(db_folder)}}
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _, {db_folder, workers}) do
    worker_pid = Map.get(workers, :erlang.phash2(key, 3))

    {:reply, worker_pid, {db_folder, workers}}
  end

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    choose_worker(key)
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    choose_worker(key)
    |> Todo.DatabaseWorker.get(key)
  end

  defp start_workers(db_folder) do
    for idx <- 0..2, into: %{} do
      {:ok, pid} = Todo.DatabaseWorker.start(db_folder)
      {idx, pid}
    end
  end

  defp choose_worker(key) do
    GenServer.call(:database_server, {:choose_worker, key})
  end
end
