defmodule NebulaWeb.V1.CdmiObjectView do
  use NebulaWeb, :view
  require Logger

  def render("cdmi_object.json", %{cdmi_object: cdmi_object}) do
    cdmi_object
  end
end
