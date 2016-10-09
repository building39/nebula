defmodule Nebula.ControllerCommon do
  @moduledoc """
  Functions common to all of the application's controllers
  """

  require Logger

  defmacro __using__(_) do

    quote do
      require Logger
      @doc """
      Fail a request.
      """
      @spec request_fail(map, atom, charlist, list) :: map
      def request_fail(conn, status, message, headers \\ []) do
        if length(headers) > 0 do
          Enum.reduce headers, conn, fn {k, v}, acc ->
            put_resp_header(acc, k, v)
          end
        else
          conn
        end
        |> put_status(status)
        |> json(%{error: message})
        |> halt()
      end

      @doc """
      Check for mandatory Content-Type header.
      """
      @spec check_content_type_header(map, charlist) :: map
      def check_content_type_header(conn, resource) do
        if (List.keymember?(conn.req_headers, "content-type", 0) and
               List.keyfind(conn.req_headers, "content-type", 0) ==
                 {"content-type", "application/cdmi-#{resource}"}) do
          conn
        else
          request_fail(conn, :bad_request,
                       "Missing Header: Content-Type: application/cdmi-#{resource}")
        end
      end
    end
  end
end
