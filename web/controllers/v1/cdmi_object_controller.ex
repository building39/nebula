defmodule Nebula.V1.CdmiObjectController do
  @moduledoc """
  Handle cdmi_object resources
  """

  use Nebula.Web, :controller
  use Nebula.ControllerCommon
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
        conn
        |> put_resp_content_type(data.cdmi.objectType)
        |> render("cdmi_object.json", cdmi_object: data)
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
