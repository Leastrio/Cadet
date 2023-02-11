defmodule Cadet.CommandStorage do
  use GenServer

  @table_name :cadet_command_storage
  @table_options [
    {:read_concurrency, true},
    {:write_concurrency, true},
    
  ]

  def start_link(_args) do

  end
end
