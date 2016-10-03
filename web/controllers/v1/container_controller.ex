defmodule Nebula.V1.ContainerController do
  use Nebula.Web, :controller

  alias Nebula.Container
  require Logger

  def index(conn, _params) do
#    containers = Repo.all(Container)
#    render(conn, "index.json", containers: containers)
  end

  def create(conn, %{"container" => container_params}) do
#    changeset = Container.changeset(%Container{}, container_params)

#    case Repo.insert(changeset) do
#      {:ok, container} ->
#        conn
#        |> put_status(:created)
#        |> put_resp_header("location", container_path(conn, :show, container))
#        |> render("show.json", container: container)
#      {:error, changeset} ->
#        conn
#        |> put_status(:unprocessable_entity)
#        |> render(Nebula.ChangesetView, "error.json", changeset: changeset)
#    end
  end

  def show(conn, %{"id" => id}) do
    Logger.debug("In container show")
    container = GenServer.call(Metadata, {:get, id})
    Logger.debug("Got container:")
    IO.inspect(container)
    render(conn, "show.json", container: container)
  end

  def update(conn, %{"id" => id, "container" => container_params}) do
#    container = Repo.get!(Container, id)
#    changeset = Container.changeset(container, container_params)

#    case Repo.update(changeset) do
#      {:ok, container} ->
#        render(conn, "show.json", container: container)
#      {:error, changeset} ->
#        conn
#        |> put_status(:unprocessable_entity)
#        |> render(Nebula.ChangesetView, "error.json", changeset: changeset)
#    end
  end

  def delete(conn, %{"id" => id}) do
#    container = Repo.get!(Container, id)
#
#    # Here we use delete! (with a bang) because we expect
#    # it to always work (and if it does not, it will raise).
#    Repo.delete!(container)
#
#    send_resp(conn, :no_content, "")
  end
end
