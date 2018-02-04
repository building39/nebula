defmodule NebulaWeb.V1.GetController do
  @moduledoc """
  Handle cdmi containers
  """

  use NebulaWeb, :controller
  use Nebula.Util.ControllerCommon

  import Nebula.Macros, only: [set_mandatory_response_headers: 2]
  import Nebula.Util.Utils, only: [get_domain_hash: 1]
  require Logger

  @doc """
  Return an object.

  If the path ends with a '/', it's a container or a queue,
  otherwise, it's a data object.

  """
  def show(conn, _params) do
    Logger.debug(fn -> "conn: #{inspect(conn)}" end)
    set_mandatory_response_headers(conn, "container")
    data = conn.assigns.data
    data = process_query_string(conn, data)

    conn
    |> check_acls(conn.method)
    |> put_status(:ok)
    |> render("container.json", container: data)
  end
end
