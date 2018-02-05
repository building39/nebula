defmodule Nebula.Util.ControllerCommon do
  @moduledoc """
  Functions common to all of the application's controllers
  """

  defmacro __using__(_) do
    quote do
      import Nebula.Constants
      import Nebula.Util.Utils
      require Logger

      @doc """
      Delete an object and all of its children
      """
      @spec delete_object(Plug.Conn.t()) :: Plug.Conn.t()
      def delete_object(conn) do
        if conn.halted do
          conn
        else
          oid = conn.assigns.data.objectID
          Task.start(__MODULE__, :handle_delete, [conn.assigns.data])
          conn
        end
      end

      @spec handle_delete(map) :: atom
      def handle_delete(obj) do
        oid = obj.objectID

        if obj.objectType == dataobject_object() do
          GenServer.call(Metadata, {:delete, oid})
        else
          children = Map.get(obj, :children, [])
          hash = get_domain_hash(obj.domainURI)
          query = "sp:" <> hash <> obj.parentURI <> obj.objectName

          if length(children) == 0 do
            GenServer.call(Metadata, {:delete, oid})
          else
            for child <- children do
              query = query <> child

              case GenServer.call(Metadata, {:search, query}) do
                {:ok, data} ->
                  handle_delete(data)

                _ ->
                  nil
              end

              GenServer.call(Metadata, {:delete, oid})
            end
          end
        end

        #        :ok
      end

      @doc """
      Check ACLs.
      This is a TODO.
      """
      @spec check_acls(Plug.Conn.t(), String.t()) :: Plug.Conn.t()
      def check_acls(conn, _method) do
        Logger.debug(fn -> "In check_acls" end)

        if conn.halted do
          conn
        else
          conn
        end
      end

      @doc """
      Check object capabilities.
      """
      @spec check_capabilities(Plug.Conn.t(), String.t()) :: Plug.Conn.t()
      def check_capabilities(conn, "DELETE") do
        Logger.debug(fn -> "In check_capabilities DELETE" end)

        if conn.halted do
          conn
        else
          container = conn.assigns.data
          query = "sp:" <> get_domain_hash(container.domainURI) <> container.capabilitiesURI
          {:ok, capabilities} = GenServer.call(Metadata, {:search, query})
          capabilities = Map.get(capabilities, :capabilities)
          delete_container = Map.get(capabilities, :cdmi_delete_container, false)

          if delete_container == "true" do
            conn
          else
            request_fail(conn, :bad_request, "Bad Request 1")
          end
        end
      end

      def check_capabilities(conn, "PUT") do
        Logger.debug(fn -> "In check_capabilities PUT" end)

        if conn.halted do
          conn
        else
          parent = conn.assigns.parent
          query = "sp:" <> get_domain_hash(parent.domainURI) <> parent.capabilitiesURI
          {:ok, capabilities} = GenServer.call(Metadata, {:search, query})
          capabilities = Map.get(capabilities, :capabilities)
          create_container = Map.get(capabilities, :cdmi_create_container, false)

          if create_container == "true" do
            conn
          else
            request_fail(conn, :bad_request, "Bad Request 2")
          end
        end
      end

      @doc """
      Check for mandatory Content-Type header.
      """
      @spec check_content_type_header(Plug.Conn.t(), String.t()) :: Plug.Conn.t()
      def check_content_type_header(conn, resource) do
        Logger.debug(fn -> "In check_content_type_header" end)

        if List.keymember?(conn.req_headers, "content-type", 0) and
             List.keyfind(conn.req_headers, "content-type", 0) ==
               {"content-type", "application/cdmi-#{resource}"} do
          conn
        else
          request_fail(
            conn,
            :bad_request,
            "Missing Header: Content-Type: application/cdmi-#{resource}"
          )
        end
      end

      @doc """
      Document the Check Domain function
      """
      @spec check_domain(Plug.Conn.t(), map) :: Plug.Conn.t()
      def check_domain(conn, data) do
        if data.objectType == capabilities_object() do
          # Capability objects don't have a domain object
          conn
        else
          domain = conn.assigns.cdmi_domain
          domain_hash = get_domain_hash("/cdmi_domains/" <> domain)
          query = "sp:" <> domain_hash <> "/cdmi_domains/#{domain}"
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

      #
      # Construct the basic object metadata
      #
      @spec construct_metadata(String.t()) :: map
      defp construct_metadata(auth_as) do
        Logger.debug(fn -> "In construct_metadata" end)
        Logger.debug(fn -> "auth_as: #{inspect(auth_as)}" end)
        timestamp = "1"
        # timestamp = List.to_string(Nebula.Util.Utils.make_timestamp())
        Logger.debug(fn -> "Hi there!" end)
        Logger.debug(fn -> "timestamp: #{inspect(timestamp)}" end)
        # Logger.debug(fn -> "assigns: #{inspect conn.assigns}" end)
        %{
          cdmi_owner: auth_as,
          cdmi_atime: timestamp,
          cdmi_ctime: timestamp,
          cdmi_mtime: timestamp,
          cdmi_acl: [
            %{
              aceflags: "0x03",
              acemask: "0x1f07ff",
              acetype: "0x00",
              identifier: "OWNER\@"
            }
          ]
        }
      end

      @doc """
      Get the parent of an object.
      """
      @spec get_parent(Plug.Conn.t()) :: map
      def get_parent(conn) do
        Logger.debug(fn -> "In get_parent" end)

        if conn.halted do
          conn
        else
          container_path = Enum.drop(conn.path_info, 3)
          parent_path = "/" <> Enum.join(Enum.drop(container_path, -1), "/")

          parent_uri =
            if String.ends_with?(parent_path, "/") do
              parent_path
            else
              parent_path <> "/"
            end

          conn = assign(conn, :parentURI, parent_uri)
          domain_hash = get_domain_hash("/cdmi_domains/" <> conn.assigns.cdmi_domain)
          query = "sp:" <> domain_hash <> parent_uri
          parent_obj = GenServer.call(Metadata, {:search, query})

          case parent_obj do
            {:ok, data} ->
              Logger.debug(fn -> "get_parent found parent #{inspect(data, pretty: true)}" end)
              assign(conn, :parent, data)

            {_, _} ->
              request_fail(conn, :not_found, "Parent container does not exist")
          end
        end
      end

      @doc """
      Process the query string.
      """
      @spec process_query_string(Plug.Conn.t(), map) :: map
      def process_query_string(conn, data) do
        handle_qs(conn, data, String.split(conn.query_string, ";"))
      end

      @doc """
      Fail a request.
      """
      @spec request_fail(Plug.Conn.t(), atom, String.t(), list) :: map
      def request_fail(conn, status, message, headers \\ []) do
        if length(headers) > 0 do
          Enum.reduce(headers, conn, fn {k, v}, acc ->
            put_resp_header(acc, k, v)
          end)
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

      @doc """
      Update an object's parent.
      """
      @spec update_parent(Plug.Conn.t(), String.t()) :: Plug.Conn.t()
      def update_parent(conn, "DELETE") do
        Logger.debug(fn -> "In update_parent DELETE" end)

        if conn.halted do
          conn
        else
          child = conn.assigns.data
          parent = conn.assigns.parent
          index = Enum.find_index(Map.get(parent, :children), fn x -> x == child.objectName end)
          children = Enum.drop(Map.get(parent, :children), index + 1)
          parent = Map.put(parent, :children, children)
          children_range = Map.get(parent, :childrenrange)

          new_range =
            case children_range do
              "0-0" ->
                ""

              _ ->
                [first, last] = String.split(children_range, "-")
                "0-" <> Integer.to_string(String.to_integer(last) - 1)
            end

          parent = Map.put(parent, :childrenrange, new_range)
          result = GenServer.call(Metadata, {:update, parent.objectID, parent})
          assign(conn, :parent, parent)
        end
      end

      def update_parent(conn, "PUT") do
        Logger.debug(fn -> "In update_parent PUT" end)

        if conn.halted do
          conn
        else
          child = conn.assigns.newobject
          parent = conn.assigns.parent
          children = Enum.concat([child.objectName], Map.get(parent, :children, []))
          parent = Map.put(parent, :children, children)
          children_range = Map.get(parent, :childrenrange, "")

          Logger.debug(fn ->
            "parent: #{inspect(parent)} children: #{inspect(children)} range: #{
              inspect(children_range)
            }"
          end)

          new_range =
            case children_range do
              "" ->
                "0-0"

              _ ->
                [first, last] = String.split(children_range, "-")
                "0-" <> Integer.to_string(String.to_integer(last) + 1)
            end

          parent = Map.put(parent, :childrenrange, new_range)
          result = GenServer.call(Metadata, {:update, parent.objectID, parent})
          assign(conn, :parent, parent)
        end
      end

      @spec write_new_object(Plug.Conn.t()) :: Plug.Conn.t()
      def write_new_object(conn) do
        Logger.debug(fn -> "In write_new_object" end)

        if conn.halted do
          conn
        else
          new_domain = conn.assigns.newobject
          key = new_domain.objectID
          parent = conn.assigns.parent
          {rc, data} = GenServer.call(Metadata, {:put, key, new_domain})

          if rc == :ok do
            conn
          else
            request_fail(conn, :service_unavailable, "Service Unavailable")
          end
        end
      end

      @spec handle_qs(Plug.Conn.t(), map, list) :: map
      defp handle_qs(conn, data, qs) when qs == [""] do
        data
      end

      defp handle_qs(conn, data, qs) do
        Enum.reduce(qs, %{}, fn qp, acc ->
          if String.contains?(qp, ":") do
            handle_subparms(qp, acc, data)
          else
            if query_parm_exists?(data, String.to_atom(qp)) do
              Map.put(acc, qp, Map.get(data, String.to_atom(qp)))
            end
          end
        end)
      end

      @spec handle_subparms(String.t(), list, map) :: map
      defp handle_subparms(qp, acc, data) do
        [qp2, val] = String.split(qp, ":")

        if query_parm_exists?(data, String.to_atom(qp2)) do
          handle_subparm(acc, data, qp2, val)
        else
          %{}
        end
      end

      @spec handle_subparm(list, map, String.t(), String.t()) :: list
      defp handle_subparm(acc, data, qp, val) when qp == "children" do
        [idx0, idx1] = String.split(val, "-")
        s = String.to_integer(idx0)
        e = String.to_integer(idx1)

        childlist =
          Enum.reduce(s..e, [], fn i, acc ->
            acc ++ List.wrap(Enum.at(data.children, i))
          end)

        Map.put(acc, String.to_atom(qp), childlist)
      end

      defp handle_subparm(acc, data, qp, val) when qp == "metadata" do
        metadata =
          Enum.reduce(data.metadata, %{}, fn {k, v}, md ->
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
