defmodule Nebula.V1.ResolveDomain do
  @moduledoc """
  Resolve the user's domain.
  """

  import Plug.Conn
  import Phoenix.Controller
  use Nebula.ControllerCommon
  require Logger

  def init(opts) do
    opts
  end

  @doc """
  Right now, everything lives in the system domain.
  User domains will be implemented later.
  """
  def call(conn, _opts) do
    Logger.debug("ResolveDomain plug")
    conn
    |> assign(:cdmi_domain, "system_domain/")
  end

end
