defmodule Nebula.Macros do
  @moduledoc """
  Various and assorted macros used throughout the application.
  """

  defmacro request_fail(conn, status, message) do
    quote do
      unquote(conn)
      |> put_status(unquote(status))
      |> json(%{error: unquote(message)})
      |> halt()
    end
  end

  defmacro check_content_type_header(conn, resource) do
    quote do
      unless(List.keymember?(unquote(conn.req_headers), unquote("content-type")) and
             List.keyfind(unquote(conn.req_headers),
                          unquote("content-type")) == {:content-type, unquote("application/cdmi-#{resource}")}) do
        request_fail(unquote(conn),
                     :bad_request,
                     unquote("Missing Header: Content-Type: application/cdmi-#{resource}"))
      end
    end
  end

  defmacro set_mandatory_response_headers(conn, resource) do
    quote do
      unquote(conn) = put_resp_header(unquote(conn),
                             unquote("X-CDMI-Specification-Version"),
                             Enum.join(Application.get_env(:nebula, :cdmi_version), unquote(",")))
      unquote(conn) = put_resp_header(unquote(conn),
                                      unquote("content-type"),
                                      unquote("application/cdmi-#{resource}"))
    end
  end

end
