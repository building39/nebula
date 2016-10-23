defmodule Nebula.V1.ContainerController do
  @moduledoc """
  Handle cdmi containers
  """

  use Nebula.Web, :controller
  use Nebula.ControllerCommon

  import Nebula.Macros, only: [
    set_mandatory_response_headers: 2]
  import Nebula.Util.Utils, only: [get_domain_hash: 1]
  require Logger

  def create(conn, _params) do
    c = conn
    |> check_content_type_header("container")
    |> check_for_dup()
    |> get_parent()
    |> check_capabilities(conn.method)
    |> check_acls(conn.method)
    |> create_new_container()
    |> write_container()
    |> update_parent(conn.method)
    if not c.halted do
      c
      |> put_status(:ok)
      |> render("container.json", container: c.assigns.newobject)
    else
      c
    end
  end

  def delete(conn, _params) do
    c = conn
    |> get_parent()
    |> check_capabilities(conn.method)
    |> check_acls(conn.method)
    |> delete_object()
    |> update_parent(conn.method)
    if not c.halted do
      c
      |> put_status(:no_content)
      |> json(nil)
    else
      c
    end
  end

  @doc """
  Return a container object.

  First, check to be sure that the path ends with a "/" character. If not,
  append one, and remember this fact.
  Next, construct the search query and attempt to retrieve the container.
  If search fails, return a 404.
  If search succeeds, but the path originally had no trailing "/", return
  a 301 along with a Location header.
  Otherwise, return the container with a 200 status.

  """
  def show(conn, _params) do
    set_mandatory_response_headers(conn, "container")
    data = conn.assigns.data
    data = process_query_string(conn, data)
    conn
    |> check_acls(conn.method)
    |> put_status(:ok)
    |> render("container.json", container: data)
  end

  def update(conn, %{"id" => _id, "container" => _container_params}) do
    request_fail(conn, :not_implemented, "Update Not Implemented")
  end

  @spec check_for_dup(map) :: map
  defp check_for_dup(conn) do
    if conn.halted do
      conn
    else
      domain_hash = get_domain_hash("/cdmi_domains/" <> conn.assigns.cdmi_domain)
      object_name = List.last(conn.path_info) <> "/"
      container_path = Enum.drop(conn.path_info, 3)
      parent_path = "/" <> Enum.join(Enum.drop(container_path, -1), "/")
      parent_uri = if String.ends_with?(parent_path, "/") do
        parent_path
      else
        parent_path <> "/"
      end
      query = "sp:" <> domain_hash <> parent_uri <> object_name
      response = GenServer.call(Metadata, {:search, query})
      case tuple_size(response) do
        2 ->
          {status, _} = response
          case status do
            :not_found ->
              conn
            :ok ->
              request_fail(conn, :conflict, "Container already exists")
          end
        3 ->
          request_fail(conn, :conflict, "Container already exists")
      end
    end
  end

  @spec construct_metadata(map) :: map
  defp construct_metadata(conn) do
    timestamp = List.to_string(Nebula.Util.Utils.make_timestamp())
    %{
      cdmi_owner: conn.assigns.authenticated_as,
      cdmi_atime: timestamp,
      cdmi_ctime: timestamp,
      cdmi_mtime: timestamp,
      cdmi_acl: [
        %{
          aceflags: "0x03",
          acemask: "0x1f07ff",
          acetype: "0x00",
          identifier: "OWNER\@"
        }
      ]
    }
  end

  @spec create_new_container(map) :: map
  defp create_new_container(conn) do
    if conn.halted do
      conn
    else
      {object_oid, object_key} = Cdmioid.generate(45241)
      object_name = List.last(conn.path_info) <> "/"
      parent = conn.assigns.parent
      new_container =
        %{
          objectType: container_object(),
          objectID: object_oid,
          objectName: object_name,
          parentURI: conn.assigns.parentURI,
          parentID: conn.assigns.parent.objectID,
          domainURI: "/cdmi_domains/" <> conn.assigns.cdmi_domain,
          capabilitiesURI: container_capabilities_uri(),
          completionStatus: "Complete",
          children: [],
          metadata: construct_metadata(conn)
        }
      assign(conn, :newobject, new_container)
    end
  end

  @spec write_container(map) :: map
  defp write_container(conn) do
    if conn.halted do
      conn
    else
      new_container = conn.assigns.newobject
      key = new_container.objectID
      parent = conn.assigns.parent
      {rc, data} = GenServer.call(Metadata, {:put, key, new_container})
      if rc == :ok do
        conn
      else
        request_fail(conn, :service_unavailable, "Service Unavailable")
      end
    end
  end

end
