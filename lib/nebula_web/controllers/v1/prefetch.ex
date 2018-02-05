defmodule Nebula.V1.Prefetch do
  import Plug.Conn
  import Phoenix.Controller
  import Nebula.Constants

  import Nebula.Macros,
    only: [
      fix_container_path: 1
    ]

  import Nebula.Util.Utils, only: [get_domain_hash: 1]
  use Nebula.Util.ControllerCommon
  require Logger

  def init(opts) do
    opts
  end

  @doc """
  Document the prefetch function
  """
  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, _opts) do
    Logger.debug("Prefetch plug")
    fetch_for_method(conn, conn.method)
  end

  @spec fetch_for_method(Plug.Conn.t(), String.t()) :: Plug.Conn.t()
  defp fetch_for_method(conn, method) when method == "DELETE" do
    handle_object_get(conn, Enum.at(conn.path_info, 2))
  end

  defp fetch_for_method(conn, method) when method == "GET" do
    Logger.debug(fn -> "In fetch_for_method #{inspect(conn, pretty: true)}" end)
    req_headers = conn.req_headers
    Logger.debug("req_headers: #{inspect(req_headers)}")
    {_, object_type} = List.keyfind(req_headers, "accept", 0, {"", ""})

    object_type2 =
      case object_type do
        "" ->
          Logger.debug("no accept header")
          ""

        "application/cdmi-container" ->
          Logger.debug("accepting cdmi-container")
          "container"

        "application/cdmi-domain" ->
          Logger.debug("accepting cdmi-domain")
          "domain"

        other ->
          Logger.error("Unknown accept header: #{inspect(other)}")
      end

    Logger.debug("object type is #{inspect(object_type2)}")
    handle_object_get(conn, object_type2)
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

  defp handle_object_get(conn, object_type) when object_type == "cdmi_capabilities" do
    conn
  end

  defp handle_object_get(conn, object_type) when object_type == "cdmi_domains" do
    conn
  end

  defp handle_object_get(conn, object_type) when object_type == "cdmi_objectid" do
    conn
  end

  defp handle_object_get(conn, object_type) when object_type == "container" or object_type == nil do
    Logger.debug("Prefetch: handle_object_get container")
    req_path = fix_container_path(conn)

    Logger.debug(fn -> "req_path: #{inspect(req_path)}" end)
    domain = conn.assigns.cdmi_domain
    domain_hash = get_domain_hash("/cdmi_domains/" <> domain)
    query = "sp:" <> domain_hash <> String.replace_prefix(req_path, "/api/v1", "")
    {rc, data} = GenServer.call(Metadata, {:search, query})

    if rc == :ok and data.objectType == container_object() do
      if not String.ends_with?(conn.request_path, "/") do
        request_fail(conn, :moved_permanently, "Moved Permanently", [{"Location", req_path}])
      end
    else
      request_fail(conn, :not_found, "Not found 2")
    end

    assign_map = conn.assigns
    assign_map = Map.put_new(assign_map, :data, data)
    Map.put(conn, :assigns, assign_map)
  end

  defp handle_object_get(conn, object_type) do
    Logger.debug(fn -> "handle_object_get got object type: #{inspect(object_type)}" end)
    Logger.debug(fn -> "connection: #{inspect(conn)}" end)
    conn
  end
end
