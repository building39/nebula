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
    IO.inspect conn
    x_cdmi_header = get_req_header(conn, "X-CDMI-Specification-Version")
    req_path = if String.ends_with?(conn.request_path, "/") do
      conn.request_path
    else
      conn.request_path <> "/"
    end
    # TODO: Finish out fetch of object

    domain = conn.assigns.cdmi_domain
    domain_hash = get_domain_hash("/cdmi_domains/" <> domain)
    query = "sp:" <> domain_hash
                  <> "/cdmi_domains/"
                  <> domain
                  <> "cdmi_domain_members/"
                  <> user
    cond do
      not String.ends_with?(conn.request_path, "/") ->
        conn
        |> put_status(301)
        |> put_resp_header("Location", conn.request_path <> "/")
        |> json(%{error: "Moved Permanently"})
        |> halt
      :else ->
        conn
        |> put_status(501)
        |> json(%{error: "Not Implemented"})
    end
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
