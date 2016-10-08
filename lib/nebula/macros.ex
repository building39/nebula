defmodule Nebula.Macros do
  @moduledoc """
  Various and assorted macros used throughout the application.
  """

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
