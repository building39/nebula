defmodule NebulaWeb.V1.CdmiObjectView do
  use NebulaWeb, :view
  require Logger

  def render("cdmi_object.cdmio", %{cdmi_object: cdmi_object}) do
    Logger.debug("object view cdmio: #{inspect(cdmi_object, pretty: true)}")
    cdmi_object
  end
end
