defmodule Nebula.V1.ContainerView do
  use Nebula.Web, :view
  require Logger

  def render("container.json", %{container: container}) do
    container
  end

end
