defmodule NebulaWeb.V1.CapabilitiesController do
  @moduledoc """
  Handle cdmi capabilities
  """

  use NebulaWeb, :controller
  use Nebula.Util.ControllerCommon

  import Nebula.Macros, only: [set_mandatory_response_headers: 2]
  import Nebula.Util.Utils, only: [get_domain_hash: 1]
  require Logger

  @doc """
  Return a capability object.

  First, check to be sure that the path ends with a "/" character. If not,
  append one, and remember this fact.
  Next, construct the search query and attempt to retrieve the capability.
  If search fails, return a 404.
  If search succeeds, but the path originally had no trailing "/", return
  a 301 along with a Location header.
  Otherwise, return the container with a 200 status.

  """
  def show(conn, _params) do
    Logger.debug("Made it into the capabilities controller")
    Logger.debug("Conn: #{inspect(conn)}")
    set_mandatory_response_headers(conn, "cdmi-capability")
    hash = get_domain_hash("/cdmi_domains/" <> conn.assigns.cdmi_domain)
    path_parts = Enum.drop(conn.path_info, 2)
    query = "sp:" <> hash <> "/" <> Enum.join(path_parts, "/") <> "/"
    {rc, data} = GenServer.call(Metadata, {:search, query})

    case rc do
      :ok ->
        data = process_query_string(conn, data)

        conn
        |> put_status(:ok)
        |> render("cdmi_capabilities.json", cdmi_capabilities: data)

      :not_found ->
        request_fail(conn, :not_found, "Not Found #{inspect(query)}")
    end
  end
end
