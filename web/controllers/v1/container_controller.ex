defmodule Nebula.V1.ContainerController do
  @moduledoc """
  Handle cdmi containers
  """

  use Nebula.Web, :controller
  import Nebula.Util.Constants, only: :macros
  alias Nebula.Container
  require Logger

  @doc """
  When a get for the root container is requested, this is where
  we end up.
  """
  def index(conn, _params) do
    Logger.debug("Entry to Controller.index")
    conn
    |> put_status(501)
    |> json(%{error: "Not Implemented"})
  end

  def create(conn, %{"container" => container_params}) do
    Logger.debug("Entry to Controller.create")
    conn
    |> put_status(501)
    |> json(%{error: "Not Implemented"})  end

  def show(conn, %{"id" => id}) do
    Logger.debug("In container show")
    container = GenServer.call(Metadata, {:get, id})
    Logger.debug("Got container:")
    IO.inspect(container)
    render(conn, "show.json", container: container)
  end

  def update(conn, %{"id" => id, "container" => container_params}) do
    Logger.debug("Entry to Controller.update")
    conn
    |> put_status(501)
    |> json(%{error: "Not Implemented"})
  end

  def delete(conn, %{"id" => id}) do
    Logger.debug("Entry to Controller.delete")
    conn
    |> put_status(501)
    |> json(%{error: "Not Implemented"})
  end
end
