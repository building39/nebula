defmodule Nebula.V1.CapabilitiesView do
  use NebulaWeb, :view
  require Logger

  def render(conn, "cdmi_capabilities.cdmia", %{cdmi_capabilities: cdmi_capabilities}) do
    Logger.debug("Now rendering #{inspect(cdmi_capabilities, pretty: true)}")
    cdmi_capabilities
  end

  def render(conn, render_type, object) do
    Logger.debug("rendering something: #{inspect(object, pretty: true)}")
    object
  end
end
