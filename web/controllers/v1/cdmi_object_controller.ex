defmodule Nebula.V1.CdmiObjectController do
  @moduledoc """
  Handle cdmi_object resources
  """

  use Nebula.Web, :controller
  require Logger

  def create(conn, %{"cdmi_object" => _params}) do
    conn
    |> put_status(501)
    |> json(%{error: "Not Implemented"})
  end

  def show(conn, %{"id" => id}) do
    cdmi_object = GenServer.call(Metadata, {:get, id})
    conn
    |> put_resp_content_type(cdmi_object.cdmi.objectType)
    |> put_resp_header("X-CDMI-Specification-Version", "1.1")
    |> render("cdmi_object.json", cdmi_object: cdmi_object)
  end

  def update(conn, %{"id" => _id, "cdmi_object" => _params}) do
    conn
    |> put_status(501)
    |> json(%{error: "Not Implemented"})
  end

  def delete(conn, %{"id" => _id}) do
    conn
    |> put_status(501)
    |> json(%{error: "Not Implemented"})
  end

end
