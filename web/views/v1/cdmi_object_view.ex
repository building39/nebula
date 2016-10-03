defmodule Nebula.V1.CdmiObjectView do
  use Nebula.Web, :view
  require Logger

  def render("index.json", %{cdmi_objects: cdmi_objects}) do
    Logger.debug("render 1")
    %{data: render_many(cdmi_objects, Nebula.V1.CdmiObjectView, "cdmi_object.json")}
  end

  def render("show.json", %{cdmi_object: cdmi_object}) do
    Logger.debug("render 2")
    %{data: render_one(cdmi_object, Nebula.V1.CdmiObjectView, "cdmi_object.json")}
  end

  def render("cdmi_object.json", %{cdmi_object: cdmi_object}) do
    Logger.debug("render 3")
    cdmi_object.cdmi
  end

end
