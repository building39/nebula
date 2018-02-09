defmodule NebulaWeb.V1.DomainView do
  use NebulaWeb, :view
  require Logger

  def render("cdmi_domain.json", %{object: object}) do
    object
  end
end
