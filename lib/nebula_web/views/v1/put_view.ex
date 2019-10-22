defmodule NebulaWeb.Views.V1.PutView do
  use NebulaWeb, :view
  require Logger

  def render("cdmi_container.json", %{cdmi_object: object}) do
    Logger.debug(fn -> "In cdmi_container render, object: #{inspect(object)}" end)
    object
  end

  def render("cdmi_object.json", %{cdmi_object: object}) do
    Logger.debug("rendering a json data object: #{inspect(object, pretty: true)}")
    object
  end

  def render("cdmi_domain.json", %{cdmi_object: object}) do
    Logger.debug("rendering a json domain object: #{inspect(object, pretty: true)}")
    object
  end

  def render("cdmi_queue.json", %{cdmi_object: object}) do
    Logger.debug("rendering a json  object: #{inspect(object, pretty: true)}")
    object
  end

  def render(render_type, %{cdmi_object: object}) do
    Logger.debug(fn -> "In cdmi_domain render, type: #{inspect(render_type)}" end)
    Logger.debug("rendering a json  object: #{inspect(object, pretty: true)}")
    object
  end

  def render(_render_type, object) do
    Logger.debug("rendering something: #{inspect(object, pretty: true)}")
    object
  end
end
