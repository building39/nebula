defmodule Nebula.V1.Prefetch do


  import Plug.Conn
  import Phoenix.Controller
  import Nebula.Constants
  import Nebula.Macros, only: [
    fix_container_path: 1
  ]
  import Nebula.Util.Utils, only: [get_domain_hash: 1]
  use Nebula.ControllerCommon
  require Logger

  def init(opts) do
    opts
  end

  @doc """
  Document the prefetch function
  """
  def call(conn, _opts) do
    fetch_for_method(conn, conn.method)
  end

  defp fetch_for_method(conn, method) when method == "DELETE" do
    conn
  end
  defp fetch_for_method(conn, method) when method == "GET" do
    Logger.debug("conn: #{inspect conn}")
    #path_info = conn.path_info
    #conn = handle_object(conn, )
    if Enum.at(conn.path_info, 2) == "container" do
      Logger.debug("Prefetching a container")
      req_path = fix_container_path(conn)
      domain = conn.assigns.cdmi_domain
      domain_hash = get_domain_hash("/cdmi_domains/" <> domain)
      query = "sp:" <> domain_hash
                    <> String.replace_prefix(req_path, "/api/v1/container", "")
      {rc, data} = GenServer.call(Metadata, {:search, query})
      Logger.debug("Data: #{inspect data}")
      if rc == :ok and data.objectType == container_object() do
        if not String.ends_with?(conn.request_path, "/") do
          request_fail(conn, :moved_permanently, "Moved Permanently", [{"Location", req_path}])
        end
      else
        request_fail(conn, :not_found, "Not found")
      end
    end
    assign_map = conn.assigns
    assign_map = Map.put_new(assign_map, :data, data)
    conn = Map.put(conn, :assigns, assign_map)
    Logger.debug("conn: #{inspect conn}")
    conn
  end
  defp fetch_for_method(conn, method) when method == "OPTIONS" do
    conn
  end
  defp fetch_for_method(conn, method) when method == "PATCH" do
    conn
  end
  defp fetch_for_method(conn, method) when method == "PUT" do
    conn
  end
  defp fetch_for_method(conn, method) when method == "PUT" do
    conn
  end


end
