defmodule NebulaWeb.V1.PutView do
  use NebulaWeb, :view
  require Logger

  def render("cdmi_domain.json", %{object: object}) do
    Logger.debug(fn -> "In cdmi_domain render, object: #{inspect(object)}" end)
    object
  end

  def render(render_type, %{object: object}) do
    Logger.debug(fn -> "In cdmi_domain render, type: #{inspect(render_type)}" end)
    object
  end
end
