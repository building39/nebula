defmodule NebulaWeb.Views.V1.ContainerView do
  use NebulaWeb, :view
  require Logger

  def render("cdmi_container.cdmic", %{object: object}) do
    Logger.debug("rendering #{inspect(object, pretty: true)}")
    object
  end
end
