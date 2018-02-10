defmodule NebulaWeb.V1.PutController do
  @moduledoc """
  Handle cdmi containers
  """

  use NebulaWeb, :controller
  use Nebula.Util.ControllerCommon

  import Nebula.Macros, only: [set_mandatory_response_headers: 2]
  import Nebula.Util.Utils, only: [get_domain_hash: 1]
  require Logger

  @spec create(Plug.Conn.t(), any) :: Plug.Conn.t()
  def create(conn, _params) do
    Logger.debug(fn -> "In create container" end)

    c =
      conn
      |> validity_check()
      |> check_domain()
      |> check_content_type_header("container")
      |> check_for_dup()
      |> get_parent()
      |> check_capabilities(:container, conn.method)
      |> check_acls(conn.method)
      |> create_new_container()
      |> write_new_object()
      |> update_parent(conn.method)

    if not c.halted do
      c
      |> put_status(:ok)
      |> render("cdmi_container.json", object: c.assigns.newobject)
    else
      c
    end
  end

  @spec delete(Plug.Conn.t(), any) :: Plug.Conn.t()
  def delete(conn, _params) do
    c =
      conn
      |> get_parent()
      |> check_capabilities(:container, conn.method)
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
  @spec show(Plug.Conn.t(), any) :: Plug.Conn.t()
  def show(conn, _params) do
    set_mandatory_response_headers(conn, "container")
    data = conn.assigns.data
    data2 = process_query_string(conn, data)

    conn
    |> check_acls(conn.method)
    |> put_status(:ok)
    |> render("container.json", container: data2)
  end

  @spec update(Plug.Conn.t(), map) :: Plug.Conn.t()
  def update(conn, %{"id" => _id, "container" => _container_params}) do
    request_fail(conn, :not_implemented, "Update Not Implemented")
  end

  @spec check_for_dup(Plug.Conn.t()) :: Plug.Conn.t()
  defp check_for_dup(conn) do
    Logger.debug(fn -> "In check_for_dup" end)

    if conn.halted do
      conn
    else
      domain_hash = get_domain_hash("/cdmi_domains/" <> conn.assigns.cdmi_domain)
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
  end

  @spec validity_check(Plug.Conn.t()) :: Plug.Conn.t()
  defp validity_check(conn) do
    Logger.debug(fn -> "In validity_check" end)

    if conn.halted == true do
      conn
    else
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
end
