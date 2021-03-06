defmodule NebulaWeb.V1.CdmiObjectController do
  @moduledoc """
  Handle cdmi_object resources
  """

  use NebulaWeb, :controller
  use NebulaWeb.Util.ControllerCommon
  import NebulaWeb.Util.Constants
  import NebulaWeb.Util.Macros, only: [set_mandatory_response_headers: 2]
  @api_prefix api_prefix()
  @capabilities_object capabilities_object()
  @container_object container_object()
  require Logger

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"cdmi_object" => _params}) do
    request_fail(conn, :not_implemented, "Not Implemented")
  end

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    handle_show(conn, GenServer.call(Metadata, {:get, id}))
  end

  @spec handle_show(Plug.Conn.t(), {atom, map}) :: Plug.Conn.t()
  defp handle_show(conn, {:ok, data}) do
    handle_show_object_type(data.objectType, conn, data)
  end

  defp handle_show(conn, {:not_found, _}) do
    request_fail(conn, :not_found, "Not found")
  end

  defp handle_show(conn, {:im_a_teapot, _}) do
    request_fail(conn, :im_a_teapot, "Not found teapot")
  end

  @spec handle_show_object_type(String.t(), Plug.Conn.t(), map) :: Plug.Conn.t()
  defp handle_show_object_type(@container_object, conn, data) do
    Logger.debug("handle_show_object_type")
    set_mandatory_response_headers(conn, "container")
    data = process_query_string(conn, data)

    if String.ends_with?(conn.request_path, "/") do
      conn
      |> put_status(:ok)
      |> render("cdmi_object.cdmio", cdmi_object: data)
    else
      location = @api_prefix <> "container" <> data.parentURI <> data.objectName
      request_fail(conn, :moved_permanently, "Moved Permanently", [{"Location", location}])
    end
  end

  defp handle_show_object_type(@capabilities_object, conn, data) do
    set_mandatory_response_headers(conn, "capabilities")
    data = process_query_string(conn, data)

    if String.ends_with?(conn.request_path, "/") do
      conn
      |> put_status(:ok)
      |> render("cdmi_object.json", cdmi_object: data)
    else
      location = @api_prefix <> "container" <> data.parentURI <> data.objectName
      request_fail(conn, :moved_permanently, "Moved Permanently", [{"Location", location}])
    end
  end

  defp handle_show_object_type(object_type, conn, _data) do
    request_fail(conn, :bad_request, "Unknown object type: #{inspect(object_type)}")
  end

  @spec update(Plug.Conn.t(), map) :: Plug.Conn.t()
  def update(conn, %{"id" => _id, "cdmi_object" => _params}) do
    request_fail(conn, :not_implemented, "Not Implemented")
  end

  @spec delete(Plug.Conn.t(), map) :: Plug.Conn.t()
  def delete(conn, %{"id" => id}) do
    response = GenServer.call(Metadata, {:get, id})

    conn2 =
      case response do
        {:ok, data} ->
          assign(conn, :data, data)

        _ ->
          request_fail(conn, :not_found, "Not Found 3")
      end

    conn3 =
      conn2
      |> get_parent()
      |> check_capabilities(:cdmi_object, conn2.method)
      |> check_acls(conn2.method)
      |> delete_object()
      |> update_parent(conn2.method)

    if not conn3.halted do
      conn3
      |> put_status(:no_content)
      |> json(nil)
    else
      conn3
    end
  end
end
