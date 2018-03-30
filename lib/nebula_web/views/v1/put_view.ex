defmodule NebulaWeb.V1.PutView do
  use NebulaWeb, :view
  require Logger

  def render("cdmi_container.json", %{cdmi_object: object}) do
    Logger.debug(fn -> "In cdmi_container render, object: #{inspect(object)}" end)
    object
  end

  def render("cdmi_container.cdmic", %{cdmi_object: object}) do
    Logger.debug(fn -> "In cdmi_container render, object: #{inspect(object)}" end)
    object
  end

  def render("cdmi_dataobject.json", %{object: object}) do
    Logger.debug("rendering a json data object: #{inspect(object, pretty: true)}")
    object
  end

  def render("cdmi_dataobject.cdmio", %{object: object}) do
    Logger.debug("rendering a json data object: #{inspect(object, pretty: true)}")
    object
  end

  def render("cdmi_domain.json", %{object: object}) do
    object
  end

  def render("cdmi_domain.cdmid", %{object: object}) do
    object
  end

  def render("cdmi_queue.json", %{object: object}) do
    object
  end

  def render("cdmi_queue.cdmiq", %{object: object}) do
    object
  end

  def render(render_type, %{object: object}) do
    Logger.debug(fn -> "In cdmi_domain render, type: #{inspect(render_type)}" end)
    object
  end
end
