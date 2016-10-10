defmodule Nebula.ControllerCommon do
  @moduledoc """
  Functions common to all of the application's controllers
  """

  require Logger

  defmacro __using__(_) do

    quote do
      require Logger
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

      @doc """
      Process the query string.
      """
      @spec process_query_string(map, map) :: map
      def process_query_string(conn, data) do
        Logger.debug("Processing the query string")
        qs = String.split(conn.query_string, ";")
        Logger.debug("The query stringlen: #{inspect length(qs)}")
        if qs != [""] do
          new_data = Enum.reduce(qs, %{}, fn(qp, acc) ->
            value = if String.contains?(qp, ":") do
              [qp2, val] = String.split(qp, ":")
              case String.to_atom(qp2) do
                :children ->
                  [idx0, idx1] = String.split(val, "-")
                  s = String.to_integer(idx0)
                  e = String.to_integer(idx1)
                  childlist = Enum.reduce(s..e, [], fn(i, acc) ->
                    acc ++ List.wrap(Enum.at(data.children, i))
                  end)
                  Map.put(acc, qp2, childlist)
                :metadata ->
                  Logger.debug("Getting metadata #{inspect val}")
                  Map.put(acc, qp2, Map.get(data.metadata, String.to_atom(val)))
              end
            else
              Map.put(acc, qp, Map.get(data, String.to_atom(qp)))
            end
          end)
        else
          Logger.debug("Returning the original data: #{inspect data}")
          data
        end
      end

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

    end
  end
end
