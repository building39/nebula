defmodule Nebula.CDMIVersion do
  @moduledoc """
  Check the X-CDMI-Specification-Version request header.
  """

  import Plug.Conn
  import Phoenix.Controller
  require Logger

  def init(opts) do
    opts
  end

  @doc """
  Check the X-CDMI-Specification-Version header against the versions in config.
  """
  def call(conn, _opts) do
    Logger.debug("Checking x-cdmi-specification-version header")
    x_cdmi_header = get_req_header(conn, "x-cdmi-specification-version")
    server_versions = Enum.join(Application.get_env(:nebula, :cdmi_version), ",")
    if length(x_cdmi_header) == 0 do
      request_fail(conn, :bad_request,
                   "Bad Request: Must supply X-CDMI-Specification-Version header",
                   [{"X-CDMI-Specification-Version", server_versions}])
    end
    client_cdmi_versions = MapSet.new(x_cdmi_header)
    server_cdmi_versions = MapSet.new(Application.get_env(:nebula, :cdmi_version))
    valid_versions = MapSet.intersection(client_cdmi_versions, server_cdmi_versions)
    if MapSet.size(valid_versions) > 0 do
      Logger.debug("Good x-cdmi-specification-version header")
      conn
    else
      Logger.debug("Bad x-cdmi-specification-version header")
      request_fail(conn, :bad_request,
                   "Bad Request: Supplied CDMI Specification Version not supported",
                   [{"X-CDMI-Specification-Version", server_versions}])
    end
  end
end
