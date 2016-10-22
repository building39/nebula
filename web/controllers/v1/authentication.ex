defmodule Nebula.V1.Authentication do
  @moduledoc """
  Handle user authentication.
  """

  import Plug.Conn
  import Phoenix.Controller
  use Nebula.ControllerCommon
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
        authentication_failed(conn, "Basic")
      _ ->
        [method, authstring] = String.split(List.to_string(auth))
        authstring = Base.decode64!(authstring)
        user = case method do
          "Basic" ->
            basic_authentication(conn.assigns.cdmi_domain, authstring)
          _ -> {"", nil}
        end
        if user do
          conn
          |> assign(:authenticated_as, user)
        else
          authentication_failed(conn, method)
        end
    end
  end

  @spec authentication_failed(map, charlist) :: map
  defp authentication_failed(conn, method) do
    request_fail(conn, :unauthorized, "Unauthorized",
                 [{"WWW-Authenticate", method}])
  end

  @spec basic_authentication(charlist, charlist) :: charlist | nil
  defp basic_authentication(domain, authstring) do
    [user, password] = String.split(authstring, ":")
        domain_hash = get_domain_hash("/cdmi_domains/" <> domain)
    query = "sp:" <> domain_hash
                  <> "/cdmi_domains/"
                  <> domain
                  <> "cdmi_domain_members/"
                  <> user
    user_obj = GenServer.call(Metadata, {:search, query})
    case user_obj do
      {:ok, data} ->
        creds = data.metadata.cdmi_member_credentials
        if creds == encrypt(user, password) do
          user
        else
          nil
        end
      {_, _} ->
        nil
    end
  end

end
