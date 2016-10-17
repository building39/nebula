defmodule Nebula.V1.Prefetch do

  import Plug.Conn

  def init(opts) do
    opts
  end

  @doc """
  Document the prefetch function
  """
  def call(conn, _opts) do
    fetch_for_method(conn)
  end

  defp fetch_for_method(conn) where conn.method == "DELETE" do
    conn
  end
  defp fetch_for_method(conn) where conn.method == "GET" do
    conn
  end
  defp fetch_for_method(conn) where conn.method == "OPTIONS" do
    conn
  end
  defp fetch_for_method(conn) where conn.method == "PATCH" do
    conn
  end
  defp fetch_for_method(conn) where conn.method == "POST" do
    conn
  end
  defp fetch_for_method(conn) where conn.method == "PUT" do
    conn
  end


end
