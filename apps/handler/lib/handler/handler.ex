defmodule Handler.Handler do 
  use GenServer 
  
  # client
  def start_link do 
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def handle(data) do 
    GenServer.cast(__MODULE__, {:handle, data})
  end

  def init([]) do 
    {:ok, :nostate}
  end

  def handle_cast({:handle, data}, state) do
    IO.inspect data
    {:noreply, state}
  end
end
