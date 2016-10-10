defmodule Nebula.V1.CdmiObjectController do
  @moduledoc """
  Handle cdmi_object resources
  """

  use Nebula.Web, :controller
  use Nebula.ControllerCommon
  import Nebula.Constants
  @api_prefix  api_prefix()
  require Logger

  def create(conn, %{"cdmi_object" => _params}) do
    request_fail(conn, :not_implemented, "Not Implemented")
  end

  def show(conn, %{"id" => id}) do
    # key (id) needs to be reversed for Riak datastore.
    key = String.slice(id, -32..-1) <> String.slice(id, 0..15)
    cdmi_object = GenServer.call(Metadata, {:get, key})
    case cdmi_object do
      {:ok, data} ->
        case data.objectType do
          container_object() ->
            if String.ends_with?(conn.request_path, "/") do
              conn
              |> put_status(:ok)
              |> render("cdmi_object.json", cdmi_object: data)
            else
              location = @api_prefix <>
                         "container" <>
                         data.parentURI <>
                         data.objectName
              request_fail(conn,
                           :moved_permanently,
                           "Moved Permanently",
                           [{"Location", location}])
            end
          :else ->
            request_fail(conn, :bad_request, "Unknown object type")
        end
      {:not_found, _} ->
        request_fail(conn, :not_found, "Not found")
    end
  end

  def update(conn, %{"id" => _id, "cdmi_object" => _params}) do
    request_fail(conn, :not_implemented, "Not Implemented")
  end

  def delete(conn, %{"id" => _id}) do
    request_fail(conn, :not_implemented, "Not Implemented")
  end

end
