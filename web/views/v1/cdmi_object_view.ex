defmodule Nebula.V1.CdmiObjectView do
  use Nebula.Web, :view
  require Logger

  def render("cdmi_object.json", %{cdmi_object: cdmi_object}) do
    cdmi_object.cdmi
  end

end
