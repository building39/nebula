defmodule Nebula.V1.DomainView do
  use Nebula.Web, :view
  require Logger

  def render("cdmi_domain.json", %{cdmi_domain: cdmi_domain}) do
    cdmi_domain
  end

end
