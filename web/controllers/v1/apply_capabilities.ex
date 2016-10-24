defmodule Nebula.V1.ApplyCapabilities do
  @moduledoc """
  Get the capabilities object for the current object.
  """

  import Plug.Conn
  import Phoenix.Controller
  import Nebula.Constants
  import Nebula.Util.Utils, only: [get_domain_hash: 1]
  use Nebula.ControllerCommon
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
    query = "sp:" <> domain_hash
                  <> system_capabilities_uri()
    {rc, data} = GenServer.call(Metadata, {:search, query})
    if rc != :ok do
      request_fail(conn, :not_found, "Not found 1")
    end
    capabilities = data.capabilities
    #Logger.debug("Capabilities: #{inspect capabilities}")
    assign(conn, :sys_capabilities, capabilities)
    #assign_map = conn.assigns
    #assign_map = Map.put_new(assign_map, :sys_capabilities, capabilities)
    #Map.put(conn, :assigns, assign_map)
  end

end
