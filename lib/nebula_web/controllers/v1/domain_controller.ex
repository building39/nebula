defmodule NebulaWeb.V1.DomainController do
  @moduledoc """
  Handle cdmi domains
  """

  use NebulaWeb, :controller
  use NebulaWeb.Util.ControllerCommon

  import NebulaWeb.Util.Utils, only: [get_domain_hash: 1]
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
      |> check_capabilities(:domain, conn.method)
      |> check_acls(conn.method)
      |> create_new_domain()

    Logger.debug("new c: #{inspect(c, pretty: true)}")

    if not c.halted do
      Logger.debug("Not halted")

      c
      |> put_status(:ok)
      |> render("cdmi_domain.json", object: c.assigns.newobject)
    else
      Logger.debug("XYZ halted")
      c
    end
  end

  @spec get_domain(Plug.Conn.t()) :: {:ok, map} | {:not_found, String.t()}
  def get_domain(conn) do
    path_parts = Enum.drop(conn.path_info, 2)
    domain = "/" <> Enum.join(path_parts, "/") <> "/"
    hash = get_domain_hash(domain)
    query = "sp:" <> hash <> domain
    {rc, data} = GenServer.call(Metadata, {:search, query})

    case rc do
      :ok ->
        {:ok, data}

      :not_found ->
        {:not_found, "Not Found #{inspect(query)}"}
    end
  end

  @spec check_for_dup(Plug.Conn.t()) :: Plug.Conn.t()
  defp check_for_dup(conn = %{halted: true}) do
    Logger.debug("Halted")
    conn
  end

  defp check_for_dup(conn) do
    Logger.debug("Check for dup")

    object_name = List.last(conn.path_info) <> "/"
    Logger.debug("Object name: #{inspect(object_name)}")

    parent_uri = conn.assigns.parent.parentURI <> conn.assigns.parent.objectName

    Logger.debug("parent uri: #{inspect(parent_uri)}")
    Logger.debug("XYZ calling get_domain_hash")
    domain_hash = get_domain_hash(parent_uri <> object_name)

    path = parent_uri <> object_name
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
        request_fail(conn, :conflict, "Domain already exists.")
    end
  end

  @spec create_new_domain(Plug.Conn.t()) :: Plug.Conn.t()
  defp create_new_domain(conn = %{halted: true}) do
    conn
  end

  defp create_new_domain(conn) do
    Logger.debug("Create New Domain")

    object_oid = Cdmioid.generate(45241)
    object_name = List.last(conn.path_info) <> "/"

    parent_uri =
      if Map.has_key?(conn.assigns.parent, :parentURI) do
        conn.assigns.parent.parentURI <> conn.assigns.parent.objectName
      else
        # It's the top level domain
        "/cdmi_domains/"
      end

    auth_as = conn.assigns.authenticated_as
    new_metadata = construct_metadata(auth_as)

    metadata =
      if Map.has_key?(conn.body_params, "metadata") do
        Map.merge(new_metadata, conn.body_params["metadata"])
      else
        new_metadata
      end

    parent_id = conn.assigns.parent.objectID

    domainURI =
      if String.starts_with?(parent_uri, "/") do
        parent_uri <> object_name
      else
        "/" <> parent_uri <> object_name
      end

    new_domain = %{
      objectType: domain_object(),
      objectID: object_oid,
      objectName: object_name,
      parentURI: parent_uri,
      parentID: parent_id,
      domainURI: domainURI,
      capabilitiesURI: domain_capabilities_uri(),
      completionStatus: "Complete",
      children: [],
      childrenrange: "",
      metadata: metadata
    }

    new_conn =
      assign(conn, :newobject, new_domain)
      |> write_new_object()
      |> update_parent(conn.method)

    domain_name = Enum.join(Enum.drop(new_conn.path_info, 3), "/") <> "/"
    Logger.debug("MLM domain_name #{inspect(domain_name)}")
    Task.start(fn -> create_new_domain_children(new_conn, domain_name) end)

    new_conn
  end

  @spec create_new_domain_children(Plug.Conn.t(), String.t()) :: no_return
  defp create_new_domain_children(conn, domain_name) do
    Logger.debug("creating domain children")
    :timer.sleep(1_000)
    create_new_domain_child(conn, "cdmi_domain_members", domain_name)
    create_new_domain_child(conn, "cdmi_domain_summary", domain_name)
  end

  @spec create_new_domain_child(Plug.Conn.t(), binary, String.t()) :: nil
  defp create_new_domain_child(conn, name, domain_name) do
    Logger.debug("creating domain child #{inspect(name)} for domain #{inspect(domain_name)}")
    temp_parentURI = "/" <> Enum.join(Enum.drop(conn.path_info, 2), "/") <> "/"
    temp_path_info = List.flatten(conn.path_info ++ [name])
    Logger.debug("temp_parentURI: #{inspect(temp_parentURI)}")
    Logger.debug("temp_path_info: #{inspect(temp_path_info)}")

    new_conn =
      conn
      # |> assign(:cdmi_domain, domain_name)
      |> assign(:parent, conn.assigns.newobject)
      |> assign(:parentURI, temp_parentURI)
      |> Map.put(:body_params, %{"domainURI" => domain_name})
      |> Map.put(:params, %{})
      |> Map.put(:path_info, temp_path_info)
      |> Map.put(:request_path, conn.request_path <> name <> "/")
      |> create_new_container()
      |> write_new_object()

    Logger.debug("new_conn: #{inspect(new_conn, pretty: true)}")
    :timer.sleep(1_000)

    new_conn =
      new_conn
      |> update_parent(conn.method)

    if name == "cdmi_domain_summary" do
      create_new_domain_child(new_conn, "cumulative", domain_name)
      create_new_domain_child(new_conn, "daily", domain_name)
      create_new_domain_child(new_conn, "monthly", domain_name)
      create_new_domain_child(new_conn, "yearly", domain_name)
    end
  end

  @spec delete(Plug.Conn.t(), any) :: Plug.Conn.t()
  def delete(conn, _params) do
    Logger.debug("In delete domain")
    {rc, data} = get_domain(conn)

    case rc do
      :ok ->
        c =
          conn
          |> assign(:data, data)
          |> get_domain_parent()
          |> check_capabilities(:domain, conn.method)
          |> check_acls(conn.method)
          |> delete_object()
          |> update_parent(conn.method)

        if not c.halted do
          Logger.debug("did something")

          c
          |> put_status(:no_content)
          |> json(nil)
        else
          Logger.debug("delete domain halted")
          c
        end

      :not_found ->
        request_fail(conn, :not_found, data)
    end
  end

  @doc """
  Get the parent of an object.
  """
  @spec get_domain_parent(Plug.Conn.t()) :: Plug.Conn.t()
  def get_domain_parent(conn = %{halted: true}) do
    conn
  end

  def get_domain_parent(conn) do
    Logger.debug("In get_domain_parent")

    Logger.debug("XYZ path_info: #{inspect(conn.path_info)}")
    domain_path = Enum.drop(conn.path_info, 2)
    parent_uri = "/" <> Enum.join(Enum.drop(domain_path, -1), "/") <> "/"
    Logger.debug("XYZ parent_uri: #{inspect(parent_uri)}")
    conn = assign(conn, :parentURI, parent_uri)
    Logger.debug("XYZ cdmi_domain: #{inspect(conn.assigns.cdmi_domain)}")
    Logger.debug("XYZ calling get_domain_hash")

    domain_hash =
      if String.starts_with?(parent_uri, "/cdmi_domains/") do
        get_domain_hash("/cdmi_domains/system_domain/")
      else
        get_domain_hash(parent_uri)
      end

    Logger.debug("XYZ calling get_domain_hash")
    query = "sp:" <> domain_hash <> parent_uri
    parent_obj = GenServer.call(Metadata, {:search, query})

    case parent_obj do
      {:ok, data} ->
        assign(conn, :parent, data)

      {_, _} ->
        request_fail(conn, :not_found, "Parent container does not exist!")
    end
  end
end
