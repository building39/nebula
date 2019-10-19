defmodule NebulaWeb.V1.GetController do
  @moduledoc """
  Handle cdmi containers
  """

  use NebulaWeb, :controller
  use NebulaWeb.Util.ControllerCommon

  import NebulaWeb.Util.Constants
  import NebulaWeb.Util.Utils, only: [get_domain_hash: 1]
  require Logger

  @doc """
  Return an object.

  If the path ends with a '/', it's a container or a queue,
  otherwise, it's a data object.

  """
  def show(conn, _params) do
    Logger.debug(fn -> "conn: #{inspect(conn, pretty: true)}" end)

    objectType = conn.assigns.data.objectType
    {_, render_type} = List.keyfind(render_object_type(), objectType, 0)

    Logger.debug("render_type: #{inspect(render_type)}")
    data = process_query_string(conn, conn.assigns.data)
    Logger.debug("Returning data: #{inspect(data, pretty: true)}")

    conn
      |> set_mandatory_response_headers(objectType)
      |> check_acls()
      |> put_status(:ok)

  end
end
