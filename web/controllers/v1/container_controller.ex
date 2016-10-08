defmodule Nebula.V1.ContainerController do
  @moduledoc """
  Handle cdmi containers
  """

  use Nebula.Web, :controller
  import Nebula.Util.Constants, only: :macros
  import Nebula.Util.Utils, only: [get_domain_hash: 1]
  alias Nebula.Container
  require Logger

  @doc """
  When a get for the root container is requested, this is where
  we end up.

  First, check to be sure that the path ends with a "/" character. If not,
  append one, and remember this fact.
  Next, construct the search query and attempt to retrieve the container.
  If search fails, return a 404.
  If search succeeds, but the path originally had no trailing "/", return
  a 301 along with a Location header.
  Otherwise, return the container with a 200 status.

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
    domain = conn.assigns.cdmi_domain
    domain_hash = get_domain_hash("/cdmi_domains/" <> domain)
    query = "sp:" <> domain_hash
                  <> String.replace_prefix(req_path, "/api/v1/container", "")
    Logger.debug("Query2: #{query}")
    {rc, data} = GenServer.call(Metadata, {:search, query})
    Logger.debug("Query response:")
    IO.inspect({rc, data})
    if rc == :ok do
      if String.ends_with?(conn.request_path, "/") do
        conn
        |> put_status(:ok)
        |> render("container.json", container: data)
      else
        conn
        |> put_status(:moved_permanently)
        |> put_resp_header("Location", req_path)
        |> json(%{error: "Moved Permanently"})
        |> halt()
      end
    else
      conn
      |> put_status(:not_found)
      |> json(%{error: "Not found"})
      |> halt()
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
