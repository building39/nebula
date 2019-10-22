defmodule NebulaWeb.Plugs.V1.ApplyCapabilities do
  @moduledoc """
  Get the capabilities object for the current object.
  """

  import Plug.Conn
  import Phoenix.Controller
  import NebulaWeb.Util.Constants
  import NebulaWeb.Util.Utils, only: [get_domain_hash: 1]
  use NebulaWeb.Util.ControllerCommon
  require Logger

  def init(opts) do
    opts
  end

  @doc """
  Document this function
  """
  def call(conn, _opts) do
    Logger.debug("ApplyCapabilities plug")
    domain_hash = get_domain_hash(system_domain_uri())
    query = "sp:" <> domain_hash <> system_capabilities_uri()
    Logger.debug("Apply capabilities is Searching...")
    {rc, capabilities} = GenServer.call(Metadata, {:search, query})
    Logger.debug("Apply capabilities found rc: #{inspect(rc)}")
    Logger.debug("Apply capabilities found data: #{inspect(capabilities)}")

    case rc do
      :ok ->
        Logger.debug("Capabilities: #{inspect(capabilities)}")
        assign(conn, :sys_capabilities, capabilities)
        Logger.debug("Conn: #{inspect(conn, pretty: true)}")
        assign_map = conn.assigns
        assign_map = Map.put_new(assign_map, :sys_capabilities, capabilities)
        Map.put(conn, :assigns, assign_map)

      _ ->
        Logger.debug("NotFound")
        request_fail(conn, :not_found, "Not found 1")
    end
  end
end
