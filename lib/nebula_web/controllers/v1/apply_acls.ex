defmodule Nebula.V1.ApplyACLs do
  @moduledoc """
  Apply Access Control List permissions to the object.
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
  Document the ACLs function
  """
  def call(conn, _opts) do
    # data = conn.assigns.data
    capabilities = conn.assigns.capabilities
    cdmi_security_access_control = Map.get(capabilities, :cdmi_security_access_control, false)
    cdmi_acl = Map.get(capabilities, :cdmi_acl, false)

    if cdmi_security_access_control && cdmi_acl do
      Logger.debug("Checking ACLs for this object")
    end

    conn
  end
end
