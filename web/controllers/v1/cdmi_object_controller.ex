defmodule Nebula.V1.CdmiObjectController do
  @moduledoc """
  Handel cdmi_object resources
  """

  use Nebula.Web, :controller
  import Nebula.Util.Constants, only: :macros
  alias Nebula.CdmiObject
  require Logger

  def index(conn, _params) do
    conn
    |> put_status(501)
    |> json(%{error: "Not Implemented"})
  end

  def create(conn, %{"cdmi_object" => cdmi_object_params}) do
    conn
    |> put_status(501)
    |> json(%{error: "Not Implemented"})
  end

  def show(conn, %{"id" => id}) do
    Logger.debug("In cdmi_object show")
    cdmi_object = GenServer.call(Metadata, {:get, id})
    conn
    |> put_resp_content_type(cdmi_object.cdmi.objectType)
    |> put_resp_header("X-CDMI-Specification-Version", "1.1")
    |> render("cdmi_object.json", cdmi_object: cdmi_object)
  end

  def update(conn, %{"id" => id, "cdmi_object" => cdmi_object_params}) do
    conn
    |> put_status(501)
    |> json(%{error: "Not Implemented"})
  end

  def delete(conn, %{"id" => id}) do
    conn
    |> put_status(501)
    |> json(%{error: "Not Implemented"})
  end

end
