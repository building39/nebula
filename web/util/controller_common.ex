defmodule Nebula.ControllerCommon do
  @moduledoc """
  Functions common to all of the application's controllers
  """

  defmacro __using__(_) do

    quote do
      import Nebula.Constants
      import Nebula.Util.Utils
      require Logger

      @doc """
      Check ACLs for this object
      """
      @spec check_acls(map, map) :: map
      def check_acls(conn, data) do
        acls = data.metadata.cdmi_acl
        owner = data.metadata.cdmi_owner
        user = conn.assigns.authenticated_as
        #Logger.debug("ACLs: #{inspect acls}")
        #Logger.debug("Owner: #{inspect owner}")
        #Logger.debug("User: #{inspect user}")
        conn
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

      @doc """
      Document the Check Domain function
      """
      @spec check_domain(map, map) :: map
      def check_domain(conn, data) do
        if data.objectType == capabilities_object() do
          # Capability objects don't have a domain object
          conn
        else
          domain = conn.assigns.cdmi_domain
          domain_hash = get_domain_hash("/cdmi_domains/" <> domain)
          query = "sp:" <> domain_hash
                        <> "/cdmi_domains/#{domain}"
          {rc, data} = GenServer.call(Metadata, {:search, query})
          if rc == :ok and data.objectType == domain_object() do
            if Map.get(data.metadata, :cdmi_domain_enabled, false) do
              conn
            else
              request_fail(conn, :forbidden, "Forbidden")
            end
          else
            request_fail(conn, :forbidden, "Forbidden")
          end
        end
      end

      @doc """
      Process the query string.
      """
      @spec process_query_string(map, map) :: {atom, map}
      def process_query_string(conn, data) do
        handle_qs(conn, data, String.split(conn.query_string, ";"))
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

      @doc """
      Check for the existence of a query parameter.
      """
      @spec query_parm_exists?(map, atom) :: boolean
      def query_parm_exists?(data, parm) do
        Map.has_key?(data, parm)
      end

      @spec handle_qs(map, map, list) :: list
      defp handle_qs(conn, data, qs) when qs == [""] do
        data
      end
      defp handle_qs(conn, data, qs) do
        Enum.reduce(qs, %{}, fn(qp, acc) ->
          if String.contains?(qp, ":") do
            handle_subparms(qp, acc, data)
          else
            if query_parm_exists?(data, String.to_atom(qp)) do
              Map.put(acc, qp, Map.get(data, String.to_atom(qp)))
            end
          end
        end)
      end

      @spec handle_subparms(charlist, list, map) :: list
      defp handle_subparms(qp, acc, data) do
        [qp2, val] = String.split(qp, ":")
        if query_parm_exists?(data, String.to_atom(qp2)) do
          handle_subparm(acc, data, qp2, val)
        end
      end

      @spec handle_subparm(list, map, charlist, charlist) :: list
      defp handle_subparm(acc, data, qp, val) when qp == "children" do
        [idx0, idx1] = String.split(val, "-")
        s = String.to_integer(idx0)
        e = String.to_integer(idx1)
        childlist = Enum.reduce(s..e, [], fn(i, acc) ->
          acc ++ List.wrap(Enum.at(data.children, i))
        end)
        Map.put(acc, String.to_atom(qp), childlist)

      end
      defp handle_subparm(acc, data, qp, val) when qp == "metadata" do
        metadata = Enum.reduce(data.metadata, %{}, fn({k, v}, md) ->
          if String.starts_with?(Atom.to_string(k), val) do
            Map.put(md, k, v)
          else
            md
          end
        end)
        Map.put(acc, :metadata, metadata)
      end
      defp handle_subparm(acc, _data, qp, _val) do
        acc
      end

    end
  end
end
