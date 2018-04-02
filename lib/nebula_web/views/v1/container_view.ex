defmodule NebulaWeb.V1.ContainerView do
  use NebulaWeb, :view
  require Logger

  def render("cdmi_container.cdmic", %{object: object}) do
    object
  end
end
