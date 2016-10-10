defmodule Nebula.Authentication do
  @moduledoc """
  Handle user authentication.
  """

  import Plug.Conn
  import Phoenix.Controller
  import Nebula.Util.Utils, only: [encrypt: 2,
                                   get_domain_hash: 1]
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
        {domain, user} = case method do
          "Basic" ->
            basic_authentication(authstring)
        end
        if user do
          conn
          |> assign(:authenticated_as, user)
          |> assign(:cdmi_domain, domain)
        else
          authentication_failed(conn, method)
        end
    end
  end

  defp authentication_failed(conn, method) do
    request_fail(conn, :unauthorized, "Unauthorized",
                 [{"WWW-Authenticate", method}])
  end

  defp basic_authentication(authstring) do
    Logger.debug("Doing basic authentication")
    [domain_user, password] = String.split(authstring, ":")
    {domain, user} = case String.contains?(domain_user, "/") do
      true -> l = String.split(domain_user, "/")
              u = List.last(l)  # get the userid
              d = String.replace_suffix(domain_user, "/#{u}", "") <> "/"
              {d, u}  # return the domain and the user
      false -> {"default", domain_user}
    end
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
          {domain, user}
        else
          {nil, nil}
        end
      {_, _} ->
        {nil, nil}
    end
  end

end
