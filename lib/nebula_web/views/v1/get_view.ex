defmodule NebulaWeb.V1.GetView do
  use NebulaWeb, :view
  require Logger

  def render("cdmi_capabilities.json", %{cdmi_object: object}) do
    object
  end

  def render("cdmi_container.json", %{cdmi_object: object}) do
    object
  end

  def render("cdmi_container.cdmic", %{cdmi_object: object}) do
    object
  end

  def render("cdmi_domain.json", %{cdmi_object: object}) do
    object
  end
end
