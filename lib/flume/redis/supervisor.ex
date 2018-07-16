defmodule Flume.Redis.Supervisor do
  @doc false
  use Application

  import Supervisor.Spec

  alias Flume.Config

  @redix_worker_prefix "flume_redix"

  def start(_type, _args) do
    if Config.get(:start_on_application) do
      start_link()
    else
      # Don't start Flume
      Supervisor.start_link([], strategy: :one_for_one)
    end
  end

  def start_link() do
    opts = [
      strategy: :one_for_one,
      max_restarts: 20,
      max_seconds: 5,
      name: __MODULE__
    ]

    Supervisor.start_link(redix_worker_spec(), opts)
  end

  def redix_worker_prefix do
    @redix_worker_prefix
  end

  # Private API

  defp redix_worker_spec() do
    pool_size = Config.redis_pool_size()

    # Create the redix children list of workers:
    for i <- 0..(pool_size - 1) do
      connection_opts =
        Keyword.put(Config.connection_opts(), :name, :"#{redix_worker_prefix()}_#{i}")

      args = [Config.redis_opts(), connection_opts]
      worker(Redix, args, id: {Redix, i})
    end
  end
end