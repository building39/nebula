defmodule Nebula.V1.ApplyCapabilities do
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
  def call(conn = %{sys_capabilitiies: _s}) do
    Logger.debug("already got capabilities")
    conn
  end
  def call(conn, _opts) do
    Logger.debug("ApplyCapabilities plug")
    domain_hash = get_domain_hash(system_domain_uri())
    query = "sp:" <> domain_hash <> system_capabilities_uri()
    {rc, capabilities} = GenServer.call(Metadata, {:search, query})

    case rc do
      :ok ->
        assign(conn, :sys_capabilities, capabilities)

      _ ->
        Logger.debug("Capabilities NotFound")
        request_fail(conn, :not_found, "Not found 1")
    end
  end
end
