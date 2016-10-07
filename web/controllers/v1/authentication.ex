defmodule Nebula.Authentication do
  @moduledoc """
  Handle user authentication.
  """

  import Plug.Conn
  import Phoenix.Controller
  import Nebula.Util.Constants, only: :macros
  import Nebula.Util.Utils, only: [encrypt: 2,
                                   get_domain_hash: 1]
  require Logger

  def init(opts) do
    Logger.debug("Auth init")
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
    [domain_user, password] = String.split(authstring, ":")
    [domain, user] = case String.contains?(domain_user, "/") do
                       true -> String.split(domain_user, "/")
                       false -> ["default", domain_user]
                     end
    Logger.debug("User: #{user}")
    Logger.debug("Pswd: #{password}")
    Logger.debug("Domain: #{domain}")
    domain_hash = get_domain_hash("/cdmi_domains/" <> domain <> "/")
    Logger.debug("Domain hash: #{domain_hash}")
    query = "sp:" <> domain_hash
                  <> "/cdmi_domains/"
                  <> domain
                  <> "/cdmi_domain_members/"
                  <> user
    Logger.debug("Query: #{query}")
    user_obj = GenServer.call(Metadata, {:search, query})
    IO.inspect(user_obj)
    creds = user_obj.cdmi.metadata.cdmi_member_credentials
    Logger.debug("Creds: #{creds}")
    creds == encrypt(user, password)
  end

end
