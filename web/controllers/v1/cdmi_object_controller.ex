defmodule Nebula.V1.CdmiObjectController do
  use Nebula.Web, :controller

  alias Nebula.CdmiObject
  require Logger

  def index(conn, _params) do
#    cdmi_objects = Repo.all(CdmiObject)
#    render(conn, "index.json", cdmi_objects: cdmi_objects)
  end

  def create(conn, %{"cdmi_object" => cdmi_object_params}) do
#    changeset = CdmiObject.changeset(%CdmiObject{}, cdmi_object_params)

#    case Repo.insert(changeset) do
#      {:ok, cdmi_object} ->
#        conn
#        |> put_status(:created)
#        |> put_resp_header("location", cdmi_object_path(conn, :show, cdmi_object))
#        |> render("show.json", cdmi_object: cdmi_object)
#      {:error, changeset} ->
#        conn
#        |> put_status(:unprocessable_entity)
#        |> render(Nebula.ChangesetView, "error.json", changeset: changeset)
#    end
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
#    cdmi_object = Repo.get!(CdmiObject, id)
#    changeset = CdmiObject.changeset(cdmi_object, cdmi_object_params)

#    case Repo.update(changeset) do
#      {:ok, cdmi_object} ->
#        render(conn, "show.json", cdmi_object: cdmi_object)
#      {:error, changeset} ->
#        conn
#        |> put_status(:unprocessable_entity)
#        |> render(Nebula.ChangesetView, "error.json", changeset: changeset)
#    end
  end

  def delete(conn, %{"id" => id}) do
#    cdmi_object = Repo.get!(CdmiObject, id)
#
#    # Here we use delete! (with a bang) because we expect
#    # it to always work (and if it does not, it will raise).
#    Repo.delete!(cdmi_object)
#
#    send_resp(conn, :no_content, "")
  end
end
