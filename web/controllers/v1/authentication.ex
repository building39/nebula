defmodule Nebula.Authentication do
  @moduledoc """
  Handle user authentication.
  """

  import Plug.Conn
#  import Nebula.Router.Helpers
  import Phoenix.Controller
  import Nebula.Util.Constants, only: :macros
  import Nebula.Util.Utils, only: [get_domain_hash: 1]
  require Logger

  def init(opts) do
    opts
  end

  @doc """
  Document the authenticate function
  """
  def call(conn, _opts) do
    Logger.debug("Doing authentication")
    auth = get_req_header(conn, "authorization")
    case auth do
      [] ->
#        assign(conn, :authenticated_as, nil)
        authentication_failed(conn, "Basic")
      _ ->
        Logger.debug("Got an auth: #{auth}")
        [method, authstring] = String.split(List.to_string(auth))
        authstring = Base.decode64!(authstring)
        Logger.debug("Auth Method: #{method}")
        Logger.debug("Auth String: #{authstring}")
        user = case method do
                "Basic" ->
                  basic_authentication(authstring)
                end
        Logger.debug("basic_authentication returned: #{user}")
        if user do
          assign(conn, :authenticated_as, user)
        else
          authentication_failed(conn, method)
        end
    end
  end

  defp authentication_failed(conn, method) do
    conn
    |> put_status(:unauthorized)
    |> put_resp_header("WWW-Authenticate", method)
    |> json(%{error: "Unauthorized"})
    |> halt()
  end

  defp basic_authentication(authstring) do
    [user, password] = String.split(authstring, ":")
    Logger.debug("User: #{user}")
    Logger.debug("Pswd: #{password}")
    domain_hash = get_domain_hash(system_domain_uri)
    Logger.debug("System Domain hash: #{domain_hash}")
    true
  end

end
