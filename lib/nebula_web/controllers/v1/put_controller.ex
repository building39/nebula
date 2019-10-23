defmodule NebulaWeb.V1.PutController do
  @moduledoc """
  Handle cdmi object creation
  """

  use NebulaWeb, :controller
  use NebulaWeb.Util.ControllerCommon

  import NebulaWeb.Util.Constants

  import NebulaWeb.Util.Utils, only: [get_domain_hash: 1]

  @compile if Mix.env() == :test, do: :export_all

  require Logger

  @container_object container_object()
  @data_object data_object()
  @domain_object domain_object()
  @domain_uri domain_uri()
  @enterprise_number enterprise_number()

  @spec create(Plug.Conn.t(), any) :: Plug.Conn.t()
  def create(conn, params) do
    Logger.debug(fn -> "In create conn: #{inspect(conn, pretty: true)}" end)

    if List.keymember?(conn.req_headers, "content-type", 0) do
      {_, content_type} = List.keyfind(conn.req_headers, "content-type", 0)
      Logger.debug(fn -> "Content-Type: #{inspect(content_type)}" end)
      do_create(conn, content_type, params)
    else
      request_fail(
        conn,
        :bad_request,
        "Missing Header: Content-Type"
      )
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
      if parent_uri == "/cdmi_domains/" do
        get_domain_hash("/cdmi_domains/system_domain/")
      else
        get_domain_hash(parent_uri)
      end

    Logger.debug("XYZ calling get_domain_hash")
    query = "sp:" <> domain_hash <> parent_uri
    parent_obj = GenServer.call(Metadata, {:search, query})

    case parent_obj do
      {:ok, data} ->
        Logger.debug("Parent:::::::::::::::::::::::::: #{inspect data, pretty: true}")
        assign(conn, :parent, data)

      {_, _} ->
        request_fail(conn, :not_found, "Parent container does not exist!")
    end
  end

  @spec do_create(Plug.Conn.t(), String.t(), any) :: Plug.Conn.t()
  defp do_create(conn = %{halted: true}, _object, _params) do
    conn
  end

  defp do_create(conn, @container_object, _params) do
    Logger.debug("creating a new container")

    c =
      conn
      |> validity_check()
      |> check_domain()
      |> check_for_dup(@container_object)
      |> get_parent()
      |> check_capabilities(:container, conn.method)
      |> check_acls()
      |> create_new_container()
      |> write_new_object()
      |> update_parent(conn.method)

    if not c.halted do
      c
      |> put_status(:ok)
      |> render("cdmi_container.json", cdmi_object: c.assigns.newobject)
    else
      c
    end
  end

  defp do_create(conn, @data_object, _params) do
    Logger.debug("creating a new data object")

    c =
      conn
      |> check_domain()
      |> check_for_dup(@data_object)
      |> get_parent()
      |> check_capabilities(:data_object, conn.method)
      |> check_acls()
      |> create_new_data_object()
      |> write_new_object()
      |> update_parent(conn.method)

    Logger.debug("new c: #{inspect(c, pretty: true)}")

    if not c.halted do
      Logger.debug("Not halted")

      c
      |> put_status(:ok)
      |> render("cdmi_object.json", cdmi_object: c.assigns.newobject)
    else
      Logger.debug("XYZ halted")
      c
    end
  end

  defp do_create(conn, @domain_object, _params) do
    Logger.debug("creating a new domain")

    c =
      conn
      |> get_domain_parent()
      |> check_for_dup(@domain_object)
      |> check_capabilities(:domain, conn.method)
      |> check_acls()
      |> create_new_domain()

    Logger.debug("new c: #{inspect(c, pretty: true)}")

    if not c.halted do
      Logger.debug("Not halted")

      c
      |> put_status(:ok)
      |> render("cdmi_domain.json", cdmi_object: c.assigns.newobject)
    else
      Logger.debug("XYZ halted")
      c
    end
  end

  @spec check_for_dup(Plug.Conn.t(), String.t()) :: Plug.Conn.t()
  defp check_for_dup(conn = %{halted: true}, @data_object) do
    conn
  end

  defp check_for_dup(conn, @container_object) do
    Logger.debug(fn -> "Check for duplicate container" end)

    domain_hash = get_domain_hash(@domain_uri <> conn.assigns.cdmi_domain)
    object_name = List.last(conn.path_info) <> "/"
    container_path = Enum.drop(conn.path_info, 3)
    parent_path = "/" <> Enum.join(Enum.drop(container_path, -1), "/")

    parent_uri =
      if String.ends_with?(parent_path, "/") do
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

  # defp check_for_dup(conn, @data_object) do
  #   conn
  # end

  defp check_for_dup(conn, @domain_object) do
    Logger.debug("Check for duplicate domain")

    object_name = List.last(conn.path_info) <> "/"
    Logger.debug("Object name: #{inspect(object_name)}")
    Logger.debug("Conn: #{inspect(conn, pretty: true)}")

    Logger.debug("setting parentURI")
    parent_uri = conn.assigns.parent.parentURI <> conn.assigns.parent.objectName
    Logger.debug("parentURI ok")

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

  @spec create_new_data_object(Plug.Conn.t()) :: Plug.Conn.t()
  defp create_new_data_object(conn = %{halted: true}) do
    conn
  end

  defp create_new_data_object(conn) do
    Logger.debug("Create New Data Object")

    object_oid = Cdmioid.generate(@enterprise_number)
    object_name = List.last(conn.path_info)
    auth_as = conn.assigns.authenticated_as
    body_params = conn.body_params

    Logger.debug("setting parentURI")
    new_data_object =
      Map.merge(
        %{
          objectType: @data_object,
          objectID: object_oid,
          objectName: object_name,
          parentURI: conn.assigns.parentURI,
          parentID: conn.assigns.parent.objectID,
          domainURI: "/cdmi_domains/" <> conn.assigns.cdmi_domain,
          capabilitiesURI: dataobject_capabilities_uri(),
          completionStatus: "Complete"
        },
        body_params
      )
      |> Map.delete(:metadata)
    Logger.debug("parentURI ok")

    Logger.debug("New data object: #{inspect(new_data_object, pretty: true)}")

    metadata =
      if Map.has_key?(body_params, "metadata") do
        new_metadata = construct_metadata(auth_as)
        supplied_metadata = conn.body_params["metadata"]
        merged_metadata = Map.merge(new_metadata, supplied_metadata)
        merged_metadata
      else
        construct_metadata(auth_as)
      end

    Logger.debug("Metadata: #{inspect(metadata, pretty: true)}")
    # If this is a new cdmi domain member, make the owner the new member.
    metadata2 =
      if Enum.any?(conn.path_info, fn x -> x == "cdmi_domain_members" end) do
        Map.put(metadata, :cdmi_owner, object_name)
      else
        metadata
      end

    Logger.debug("Metadata:2 #{inspect(metadata2, pretty: true)}")
    new_data_object2 = Map.put(new_data_object, :metadata, metadata2)
    Logger.debug("New data object2: #{inspect(new_data_object2, pretty: true)}")
    assign(conn, :newobject, new_data_object2)
  end

  @spec create_new_domain(Plug.Conn.t()) :: Plug.Conn.t()

  defp create_new_domain(conn = %{halted: true}) do
    conn
  end

  defp create_new_domain(conn) do
    Logger.debug("Create New Domain")
    object_oid = Cdmioid.generate(@enterprise_number)
    object_name = List.last(conn.path_info) <> "/"

    parent_uri =
      if Map.has_key?(conn.assigns.parent, :parentURI) do
        conn.assigns.parent.parentURI <> conn.assigns.parent.objectName
      else
        # It's the top level domain
        @domain_uri
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

    Logger.debug("domainURI: #{inspect domainURI}")
    Logger.debug("New Domain: #{inspect new_domain, pretty: true}")
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
    Logger.debug("newobject: #{inspect conn.assigns.newobject}")
    # |> assign(:cdmi_domain, domain_name)
    new_conn =
      conn
      |> assign(:parent, conn.assigns.newobject)
      |> assign(:parentURI, temp_parentURI)
      |> Map.put(:body_params, %{"domainURI" => domain_name})
      |> Map.put(:params, %{})
      |> Map.put(:path_info, temp_path_info)
      |> Map.put(:request_path, conn.request_path <> name <> "/")
      |> create_new_container()
      |> write_new_object()

    Logger.debug("new_conn: #{inspect(new_conn, pretty: true)}")
    Logger.debug("Assign: #{inspect new_conn.assigns, pretty: true}")
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

  @spec validity_check(Plug.Conn.t()) :: Plug.Conn.t()
  defp validity_check(conn = %{halted: true}) do
    Logger.debug(fn -> "In validity_check - halted" end)
    conn
  end

  defp validity_check(conn) do
    Logger.debug(fn -> "In validity_check" end)

    path = conn.request_path
    object_name = List.last(conn.path_info)

    cond do
      not String.ends_with?(path, "/") ->
        request_fail(conn, :bad_request, "Container name must end with a \"/\"")

      String.starts_with?(object_name, "cdmi_") ->
        request_fail(conn, :bad_request, "Container name must must not start with \"cdmi_\"")

      true ->
        conn
    end
  end
end
