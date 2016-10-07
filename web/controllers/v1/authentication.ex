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
    opts
  end

  @doc """
  Document the authenticate function
  """
  def call(conn, _opts) do
    auth = get_req_header(conn, "authorization")
    case auth do
      [] ->
#        assign(conn, :authenticated_as, nil)
        authentication_failed(conn, "Basic")
      _ ->
        [method, authstring] = String.split(List.to_string(auth))
        authstring = Base.decode64!(authstring)
        user = case method do
          "Basic" ->
            basic_authentication(authstring)
        end
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
    domain_hash = get_domain_hash("/cdmi_domains/" <> domain <> "/")
    query = "sp:" <> domain_hash
                  <> "/cdmi_domains/"
                  <> domain
                  <> "/cdmi_domain_members/"
                  <> user
    user_obj = GenServer.call(Metadata, {:search, query})
    creds = user_obj.cdmi.metadata.cdmi_member_credentials
    if creds == encrypt(user, password) do
      user
    else
      nil
    end
  end

end
