defmodule Nebula.V1.CapabilitiesView do
  use Nebula.Web, :view
  require Logger

  def render("cdmi_capabilities.json", %{cdmi_capabilities: cdmi_capabilities}) do
    cdmi_capabilities
  end
end
