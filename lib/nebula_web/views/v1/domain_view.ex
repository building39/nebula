defmodule NebulaWeb.V1.DomainView do
  use NebulaWeb, :view
  require Logger

  def render("cdmi_domain.json", %{cdmi_domain: cdmi_domain}) do
    cdmi_domain
  end
end
