defmodule Watcher.FeedWatcher do
  @behaviour :gen_server
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use GenServer

  #client 
  def start_link(url) do 
    GenServer.start_link(__MODULE__, [url], [])
  end
  
  #server 
  def init(url) do 
    send(self, :fetch)
    {:ok, {url, Timex.now}}
  end

  def handle_info(:fetch, state={url, last_time}) do 
    :timer.send_after(1000, :fetch)
    {:ok, feed} = fetch_feed(url)
    {:ok, entries} = feed.entries |> parse_times 
    {:ok, new_entries} = entries |> filter_entries(last_time)
    case new_entries do 
      [] ->
        {:noreply, state}
      new = [newest | _] ->
        Enum.each(new, fn(x) -> Handler.Handler.handle(x) end) 
        {:noreply, {url, newest.updated}}
    end 
  end

  defp parse_times(entries) do 
    parsed = entries 
             |> Enum.map(fn(x) ->  
               %FeederEx.Entry{x | updated: Timex.parse!(x.updated, "{RFC1123}")} end)
    {:ok, parsed}
  end

  defp filter_entries(entries, last_time) do 
    IO.inspect entries
    filtered = Enum.filter(entries, fn(x) -> 
        Timex.after?(x.updated, last_time) 
      end)
    {:ok, filtered}
  end

  defp fetch_feed(url) do 
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(url)
    {:ok, feed, _} = FeederEx.parse(body)
    {:ok, feed}
  end
end
