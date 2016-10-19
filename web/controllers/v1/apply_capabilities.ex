defmodule Nebula.V1.ApplyCapabilities do
  @moduledoc """
  Get the capabilities object for the current object.
  """

  import Plug.Conn
  import Phoenix.Controller
  import Nebula.Constants
  import Nebula.Macros, only: [
    fix_container_path: 1
  ]
  import Nebula.Util.Utils, only: [get_domain_hash: 1]
  use Nebula.ControllerCommon
  require Logger

  def init(opts) do
    opts
  end

  @doc """
  Document the prefetch function
  """
  def call(conn, _opts) do
    cap_uri = conn.assigns.data.capabilitiesURI
    domain = conn.assigns.cdmi_domain
    domain_hash = get_domain_hash("/cdmi_domains/" <> domain)
    query = "sp:" <> domain_hash
                  <> cap_uri
    {rc, data} = GenServer.call(Metadata, {:search, query})
    capabilities = data.capabilities
    Logger.debug("Capabilities: #{inspect capabilities}")
    assign_map = conn.assigns
    assign_map = Map.put_new(assign_map, :capabilities, capabilities)
    Map.put(conn, :assigns, assign_map)
  end

end
