defmodule Nebula.V1.ContainerController do
  @moduledoc """
  Handle cdmi containers
  """

  use Nebula.Web, :controller
  use Nebula.ControllerCommon
  import Nebula.Macros, only: [set_mandatory_response_headers: 2]
  import Nebula.Util.Utils, only: [get_domain_hash: 1]
  require Logger

  def create(conn, _params) do
    Logger.debug("Entry to Controller.create")
    request_fail(conn, :not_implemented, "Create Not Implemented")
  end

  @doc """
  Return a container object.

  First, check to be sure that the path ends with a "/" character. If not,
  append one, and remember this fact.
  Next, construct the search query and attempt to retrieve the container.
  If search fails, return a 404.
  If search succeeds, but the path originally had no trailing "/", return
  a 301 along with a Location header.
  Otherwise, return the container with a 200 status.

  """
  def show(conn, _params) do
    Logger.debug("Entry to Controller.show")
    set_mandatory_response_headers(conn, "container")
    req_path = if String.ends_with?(conn.request_path, "/") do
      conn.request_path
    else
      conn.request_path <> "/"
    end
    domain = conn.assigns.cdmi_domain
    domain_hash = get_domain_hash("/cdmi_domains/" <> domain)
    query = "sp:" <> domain_hash
                  <> String.replace_prefix(req_path, "/api/v1/container", "")
    {rc, data} = GenServer.call(Metadata, {:search, query})
    if rc == :ok and data.cdmi.objectType == "application/cdmi-container" do
      if String.ends_with?(conn.request_path, "/") do
        conn
        |> put_status(:ok)
        |> render("container.json", container: data)
      else
        request_fail(conn, :moved_permanently, "Moved Permanently", [{"Location", req_path}])
      end
    else
      request_fail(conn, :not_found, "Not found")
    end
  end

  def update(conn, %{"id" => _id, "container" => _container_params}) do
    Logger.debug("Entry to Controller.update")
    request_fail(conn, :not_implemented, "Update Not Implemented")
  end

  def delete(conn, %{"id" => _id}) do
    Logger.debug("Entry to Controller.delete")
    request_fail(conn, :not_implemented, "Delete Not Implemented")
  end
end
