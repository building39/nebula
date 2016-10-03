defmodule Nebula.V1.ContainerView do
  use Nebula.Web, :view

  def render("index.json", %{containers: containers}) do
    %{data: render_many(containers, Nebula.V1.ContainerView, "container.json")}
  end

  def render("show.json", %{container: container}) do
    %{data: render_one(container, Nebula.V1.ContainerView, "container.json")}
  end

  def render("container.json", %{container: container}) do
    %{id: container.cdmi.objectID}
  end

end
