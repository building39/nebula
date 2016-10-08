defmodule Nebula.CDMIVersion do
  @moduledoc """
  Check the X-CDMI-Specification-Version request header.
  """

  import Plug.Conn
  import Phoenix.Controller
  import Nebula.Util.Constants, only: :macros
  require Logger

  def init(opts) do
    opts
  end

  @doc """
  Check the X-CDMI-Specification-Version header against the versions in config.
  """
  def call(conn, _opts) do
    x_cdmi_header = get_req_header(conn, "x-cdmi-specification-version")
    sv = Application.get_env(:nebula, :cdmi_version)
    if length(x_cdmi_header) == 0 do
      conn
      |> put_status(:bad_request)
      |> put_resp_header("X-CDMI-Specification-Version",
                         Enum.join(Application.get_env(:nebula, :cdmi_version), ","))
      |> json(%{error: "Bad Request: Must supply X-CDMI-Specification-Version header"})
      |> halt()
    end
    client_cdmi_versions = MapSet.new(x_cdmi_header)
    server_cdmi_versions = MapSet.new(Application.get_env(:nebula, :cdmi_version))
    valid_versions = MapSet.intersection(client_cdmi_versions, server_cdmi_versions)
    if MapSet.size(valid_versions) > 0 do
      conn
    else
      conn
      |> put_status(:bad_request)
      |> put_resp_header("X-CDMI-Specification-Version",
                         Enum.join(Application.get_env(:nebula, :cdmi_version), ","))
      |> json(%{error: "Bad Request: Supplied CDMI Specification Version not supported"})
      |> halt()
    end
  end
end
