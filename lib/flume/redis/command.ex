defmodule Flume.Redis.Command do
  @match "MATCH"

  @hdel "HDEL"
  @hincrby "HINCRBY"
  @hmget "HMGET"
  @hscan "HSCAN"
  @hset "HSET"
  @llen "LLEN"

  @doc """
  Prepares HDEL commands for list of {hash, key} pairs
  ## Examples
    iex> Flume.Redis.Preparer.hdel([{"hash_1", "key_1"}, {"hash_1", "key_2"}, {"hash_2", "key_1"}])
    [["HDEL", "hash_1", "key_1", "key_2"], ["HDEL", "hash_2", "key_1"]]
  """
  def hdel(hash_key_list) when hash_key_list |> is_list() do
    hash_key_list
    |> Enum.group_by(&(&1 |> elem(0)))
    |> Enum.map(fn {hash, hash_key_list} ->
      keys =
        hash_key_list
        |> Enum.map(&(&1 |> elem(1)))

      hdel(hash, keys)
    end)
  end

  def hdel(hash, keys) when keys |> is_list() do
    [@hdel, hash] ++ keys
  end

  def hdel(hash, key) do
    [@hdel, hash, key]
  end

  def hincrby(hash, key, increment \\ 1), do: [@hincrby, hash, key, increment]

  def hmget(hash_key_list) when hash_key_list |> is_list() do
    hash_key_list |> Enum.map(fn {hash, keys} -> hmget(hash, keys) end)
  end

  def hmget(hash, keys) when keys |> is_list() do
    [@hmget, hash] ++ keys
  end

  def hmget(hash, key) do
    [@hmget, hash, key]
  end

  def hscan(attr_list) when attr_list |> is_list() do
    attr_list
    |> Enum.map(fn
      [_, _] = attrs -> apply(&hscan/2, attrs)
      [_, _, _] = attrs -> apply(&hscan/3, attrs)
    end)
  end

  def hscan(hash, cursor), do: [@hscan, hash, cursor]

  def hscan(hash, cursor, pattern), do: [@hscan, hash, cursor, @match, pattern]

  def hset(hash, key, value), do: [@hset, hash, key, value]

  @doc """
  Returns command for getting the length of a list.

  ## Examples
      iex> Flume.Redis.Command.llen("flume:test:stack")
      ["LLEN", "flume:test:stack"]
  """
  def llen(key), do: [@llen, key]
end
