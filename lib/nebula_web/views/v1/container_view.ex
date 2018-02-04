defmodule NebulaWeb.V1.ContainerView do
  use NebulaWeb, :view
  require Logger

  def render("container.json", %{container: container}) do
    container
  end
  def render("container.cdmic", %{container: container}) do
    container
  end
end
