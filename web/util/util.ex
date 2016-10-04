defmodule Nebula.Utils do
  @moduledoc """
  Various utility functions
  """

  @doc """
  Calculate a hash for a domain
  """
  def get_domain_hash(domain) when is_list(domain) do
    get_domain_hash(<<domain>>)
  end
  def get_domain_hash(domain) when is_binary(domain) do
    :crypto.hmac(:sha, <<"domain">>, domain)
    |> Base.encode16
    |> String.downcase
  end

end
