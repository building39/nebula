defmodule NebulaWeb.V1.DomainController do
  @moduledoc """
  Handle cdmi domains
  """

  use NebulaWeb, :controller
  use Nebula.Util.ControllerCommon

  import Nebula.Macros, only: [set_mandatory_response_headers: 2]
  import Nebula.Util.Utils, only: [get_domain_hash: 1]
  require Logger

  @doc """
  Create a new domain
  """
  @spec create(Plug.Conn.t(), any) :: Plug.Conn.t()
  def create(conn, _params) do
    Logger.debug("creating a new domain")

    c =
      conn
      |> check_content_type_header("domain")
      |> get_domain_parent()
      |> check_for_dup()
      |> check_capabilities(conn.method)
      |> check_acls(conn.method)
      |> create_new_domain()
      |> write_new_object()
      |> update_parent(conn.method)

    if not c.halted do
      c
      |> put_status(:ok)
      |> render("container.json", container: c.assigns.newobject)
    else
      c
    end
  end

  @doc """
  Return a Domain object.

  First, check to be sure that the path ends with a "/" character. If not,
  append one, and remember this fact.
  Next, construct the search query and attempt to retrieve the domain.
  If search fails, return a 404.
  If search succeeds, but the path originally had no trailing "/", return
  a 301 along with a Location header.
  Otherwise, return the container with a 200 status.

  """
  @spec show(Plug.Conn.t(), any) :: Plug.Conn.t()
  def show(conn, _params) do
    Logger.debug("Made it into the domain controller")
    Logger.debug("Conn: #{inspect(conn)}")
    set_mandatory_response_headers(conn, "cdmi-domain")
    hash = get_domain_hash("/cdmi_domains/" <> conn.assigns.cdmi_domain)
    path_parts = Enum.drop(conn.path_info, 2)
    query = "sp:" <> hash <> "/" <> Enum.join(path_parts, "/") <> "/"
    {rc, data} = GenServer.call(Metadata, {:search, query})

    case rc do
      :ok ->
        data = process_query_string(conn, data)

        conn
        |> put_status(:ok)
        |> render("cdmi_domain.json", cdmi_domain: data)

      :not_found ->
        request_fail(conn, :not_found, "Not Found #{inspect(query)}")
    end
  end

  @spec check_for_dup(Plug.Conn.t()) :: Plug.Conn.t()
  defp check_for_dup(conn) do
    Logger.debug("Check for dup")

    if conn.halted do
      Logger.debug("Halted")
      conn
    else
      object_name = List.last(conn.path_info) <> "/"
      Logger.debug("Object name: #{inspect(object_name)}")

      parent_uri =
        if Map.has_key?(conn.assigns.parent, :parentURI) do
          conn.assigns.parent.parentURI <> conn.assigns.parent.objectName
        else
          # It's the root
          "/"
        end

      Logger.debug("parent uri: #{inspect(parent_uri)}")
      domain_hash = get_domain_hash(parent_uri <> "cdmi_domains/" <> object_name)

      path = parent_uri <> "cdmi_domains/" <> object_name
      query = "sp:" <> domain_hash <> path
      Logger.debug("Searching for #{inspect(query)}")
      response = GenServer.call(Metadata, {:search, query})
      Logger.debug("Response from search: #{inspect(response)}")

      case tuple_size(response) do
        2 ->
          {status, _} = response

          case status do
            :not_found ->
              conn

            :ok ->
              request_fail(conn, :conflict, "Domain already exists")
          end

        3 ->
          request_fail(conn, :conflict, "Domain already exists")
      end
    end
  end

  @spec create_new_domain(Plug.Conn.t()) :: Plug.Conn.t()
  defp create_new_domain(conn) do
    Logger.debug("Create New Domain")

    if conn.halted do
      conn
    else
      {object_oid, _object_key} = Cdmioid.generate(45241)
      object_name = List.last(conn.path_info) <> "/"
      parent = conn.assigns.parent

      parent_uri =
        if Map.has_key?(conn.assigns.parent, :parentURI) do
          conn.assigns.parent.parentURI <> conn.assigns.parent.objectName
        else
          # It's the top level domain
          "/cdmi_domains/"
        end

      auth_as = conn.assigns.authenticated_as
      Logger.debug(fn -> "authenticated as #{inspect(auth_as)}" end)
      new_metadata = construct_metadata(auth_as)

      metadata =
        if Map.has_key?(conn.body_params, "metadata") do
          Map.merge(construct_metadata(auth_as), conn.body_params["metadata"])
        else
          construct_metadata(auth_as)
        end

      Logger.debug("allocating new domain object #{inspect(parent)}")

      new_domain = %{
        objectType: domain_object(),
        objectID: object_oid,
        objectName: object_name,
        parentURI: parent_uri,
        parentID: conn.assigns.parent.objectID,
        domainURI: "/cdmi_domains/" <> parent <> object_name,
        capabilitiesURI: domain_capabilities_uri(),
        completionStatus: "Complete",
        children: [],
        metadata: metadata
      }

      assign(conn, :newobject, new_domain)
    end
  end

  @doc """
  Get the parent of an object.
  """
  @spec get_domain_parent(Plug.Conn.t()) :: Plug.Conn.t()
  def get_domain_parent(conn) do
    if conn.halted do
      conn
    else
      container_path = Enum.drop(conn.path_info, 3)
      parent_path = "/" <> Enum.join(Enum.drop(container_path, -1), "/")

      parent_uri =
        if String.ends_with?(parent_path, "/") do
          parent_path
        else
          parent_path <> "/cdmi_domains/"
        end

      conn = assign(conn, :parentURI, parent_uri)
      domain_hash = get_domain_hash("/cdmi_domains/" <> conn.assigns.cdmi_domain)
      query = "sp:" <> domain_hash <> parent_uri
      parent_obj = GenServer.call(Metadata, {:search, query})

      case parent_obj do
        {:ok, data} ->
          assign(conn, :parent, data)

        {_, _} ->
          request_fail(conn, :not_found, "Parent container does not exist")
      end
    end
  end
end
