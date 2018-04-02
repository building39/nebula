defmodule Nebula.V1.CapabilitiesView do
  use NebulaWeb, :view
  require Logger

  def render("cdmi_capabilities.cdmia", %{cdmi_capabilities: cdmi_capabilities}) do
    cdmi_capabilities
  end
end
