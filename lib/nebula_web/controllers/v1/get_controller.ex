defmodule NebulaWeb.V1.GetController do
  @moduledoc """
  Handle cdmi containers
  """

  use NebulaWeb, :controller
  use NebulaWeb.Util.ControllerCommon

  import NebulaWeb.Util.Constants
  import NebulaWeb.Util.Macros, only: [set_mandatory_response_headers: 2]
  import NebulaWeb.Util.Utils, only: [get_domain_hash: 1]
  require Logger

  @doc """
  Return an object.

  If the path ends with a '/', it's a container or a queue,
  otherwise, it's a data object.

  """
  def show(conn, _params) do
    Logger.debug(fn -> "conn: #{inspect(conn, pretty: true)}" end)

    data = process_query_string(conn, conn.assigns.data)
    conn2 = set_mandatory_response_headers(conn, data.objectType)
    Logger.debug("response headers set")

    {_, render_type} = List.keyfind(render_object_type(), data.objectType, 0)
    Logger.debug("render_type: #{inspect render_type}")

    conn2
    |> check_acls(conn2.method)
    |> put_status(:ok)
    |> render(render_type, cdmi_object: data)
  end

end
