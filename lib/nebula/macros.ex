defmodule Nebula.Macros do
  @moduledoc """
  Various and assorted macros used throughout the application.
  """

  defmacro fix_container_path(conn) do
    quote do
      if String.ends_with?(unquote(conn).request_path, "/") do
        unquote(conn).request_path
      else
        unquote(conn).request_path <> "/"
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
