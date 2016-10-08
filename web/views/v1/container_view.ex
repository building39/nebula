defmodule Nebula.V1.ContainerView do
  use Nebula.Web, :view
  require Logger

  def render("index.json", %{container: container}) do
    Logger.debug("In container view render index.json")
    IO.inspect(container)
    %{data: render_one(container, Nebula.V1.ContainerView, "container.json")}
  end

  def render("show.json", %{container: container}) do
    %{data: render_one(container, Nebula.V1.ContainerView, "container.json")}
  end

  def render("container.json", %{container: container}) do
    container.cdmi
  end

end
