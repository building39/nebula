defmodule Nebula.Util.Utils do
  @moduledoc """
  Various utility functions
  """

  @doc """
  Encrypt.
  """
  @spec encrypt(charlist, charlist) :: charlist
  def encrypt(key, message) do
    :crypto.hmac(:sha, key, message)
    |> Base.encode16()
    |> String.downcase()
  end

  @doc """
  Calculate a hash for a domain.
  """
  @spec get_domain_hash(charlist) :: charlist
  def get_domain_hash(domain) when is_list(domain) do
    get_domain_hash(<<domain>>)
  end

  @spec get_domain_hash(binary) :: charlist
  def get_domain_hash(domain) when is_binary(domain) do
    :crypto.hmac(:sha, <<"domain">>, domain)
    |> Base.encode16()
    |> String.downcase()
  end

  @doc """
  Return a timestamp in the form of "2015-12-25T16:39:1451083144.000000Z"
  """
  @spec make_timestamp() :: charlist
  def make_timestamp() do
    {{year, month, day}, {hour, minute, second}} =
      :calendar.now_to_universal_time(:os.timestamp())

    List.flatten(
      :io_lib.format("~4..0w-~2..0w-~2..0wT~2..0w:~2..0w:~2..0w.000000Z", [
        year,
        month,
        day,
        hour,
        minute,
        second
      ])
    )
  end
end
