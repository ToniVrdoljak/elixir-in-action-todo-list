defmodule Todo.Database do
  use GenServer

  @impl GenServer
  def init(db_folder) do
    File.mkdir_p(db_folder)
    {:ok, db_folder}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, db_folder) do
    spawn(fn ->
      File.mkdir_p!(db_folder)

      file_name(db_folder, key)
      |> File.write!(:erlang.term_to_binary(data))
    end)

    {:noreply, db_folder}
  end

  @impl GenServer
  def handle_call({:get, key}, caller, db_folder) do
    spawn(fn ->
      data =
        case File.read(file_name(db_folder, key)) do
          {:ok, contents} -> :erlang.binary_to_term(contents)
          _ -> nil
        end

      GenServer.reply(caller, data)
    end)

    {:noreply, db_folder}
  end

  defp file_name(db_folder, key) do
    Path.join(db_folder, to_string(key))
  end

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    GenServer.cast(:database_server, {:store, key, data})
  end

  def get(key) do
    GenServer.call(:database_server, {:get, key})
  end
end
