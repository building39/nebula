defmodule NebulaWeb.V1.PostController do
  @moduledoc """
  Handle cdmi updates
  """

  use NebulaWeb, :controller
  use Nebula.Util.ControllerCommon

  import Nebula.Macros, only: [
    set_mandatory_response_headers: 2
  ]
  import Nebula.Util.Utils, only: [get_domain_hash: 1]
  require Logger

  @spec create(Plug.Conn.t(), any) :: Plug.Conn.t()
  def create(conn, params) do
    Logger.debug(fn -> "In create" end)
    if List.keymember?(conn.req_headers, "content-type", 0) do
         content_type = List.keyfind(conn.req_headers, "content-type", 0)
         create(conn, content_type, params)
    else
      request_fail(
        conn,
        :bad_request,
        "Missing Header: Content-Type"
      )
    end

  @spec(Plug.Conn.t(), String.t, any) :: Plug.Conn.t()
  defp create(conn, container_object, _params) do
    c =
      conn
      |> validity_check()
      |> check_domain()
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
