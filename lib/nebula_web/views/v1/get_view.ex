defmodule NebulaWeb.V1.GetView do
  use NebulaWeb, :view
  require Logger

  def render("cdmi_capabilities.json", %{cdmi_object: object}) do
    Logger.debug("Now rendering #{inspect(object, pretty: true)}")
    object
  end

  def render("cdmi_container.json", %{cdmi_object: object}) do
    Logger.debug("Now rendering #{inspect(object, pretty: true)}")
    object
  end

  def render("cdmi_domain.json", %{cdmi_object: object}) do
    Logger.debug("Now rendering #{inspect(object, pretty: true)}")
    object
  end

  def render("cdmi_object.json", %{cdmi_object: object}) do
    Logger.debug("Now rendering #{inspect(object, pretty: true)}")
    object
  end

  def render("cdmi_queue.json", %{cdmi_object: object}) do
    Logger.debug("Now rendering #{inspect(object, pretty: true)}")
    object
  end
  def render(object_type, object) do
    Logger.debug("Now rendering object type #{inspect(object_type, pretty: true)}")
    Logger.debug("Now rendering #{inspect(object, pretty: true)}")
    object
  end

end
