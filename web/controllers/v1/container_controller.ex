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
    new_container = create_new_container(conn)
    # key (id) needs to be reversed for Riak datastore.
    key = String.slice(new_container.cdmi.objectID, -32..-1) <>
          String.slice(new_container.cdmi.objectID, 0..15)
    {:ok, data} = GenServer.call(Metadata, {:put, key, new_container})
    conn
    |> check_content_type_header("container")
#    |> check_acls(new_container)
    |> put_status(:ok)
    |> render("container.json", container: new_container)
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
    |> check_acls(data)
    |> put_status(:ok)
    |> render("container.json", container: data)
  end

  def update(conn, %{"id" => _id, "container" => _container_params}) do
    Logger.debug("Entry to Controller.update")
    request_fail(conn, :not_implemented, "Update Not Implemented")
  end

  def delete(conn, %{"id" => _id}) do
    Logger.debug("Entry to Controller.delete")
    request_fail(conn, :not_implemented, "Delete Not Implemented")
  end

  @spec construct_metadata(map) :: map
  defp construct_metadata(conn) do
    timestamp = List.to_string(Nebula.Util.Utils.make_timestamp())
    Logger.debug("authenticated as: #{inspect conn.assigns.authenticated_as}")
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
    object_name = List.last(conn.path_info)
    {object_oid, object_key} = Cdmioid.generate(45241)
    container_path = Enum.drop(conn.path_info, 3)
    parent_path = "/" <> Enum.join(Enum.drop(container_path, -1), "/")
    parent_uri = if String.ends_with?(parent_path, "/") do
      parent_path
    else
      parent_path <> "/"
    end
    domain_hash = get_domain_hash("/cdmi_domains/" <> conn.assigns.cdmi_domain)
    query = "sp:" <> domain_hash <> parent_uri
    parent_obj = GenServer.call(Metadata, {:search, query})
    parent_oid = case parent_obj do
      {:ok, data} ->
        data.objectID
      {_, _} ->
        nil
    end
    full_path = case String.length(parent_path) do
      1 ->

    end
    if parent_oid do
      %{
        sp: domain_hash <> "/" <> Enum.join(Enum.drop(conn.path_info, 3), "/") <> "/",
        cdmi: %{
          objectType: container_object(),
          objectID: object_oid,
          objectName: object_name,
          parentURI: parent_uri,
          parentID: parent_oid,
          domainURI: "/cdmi_domains/" <> conn.assigns.cdmi_domain,
          capabilitiesURI: container_capabilities_uri(),
          completionStatus: "Complete",
          children: [],
          metadata: construct_metadata(conn)
        }
      }
    else
      request_fail(conn, :not_found, "Parent object not found")
    end
  end
end
