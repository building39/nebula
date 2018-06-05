defmodule NebulaWeb.V1.PutControllerTest do
  use NebulaWeb.ConnCase

  require Logger

  alias NebulaWeb.Container
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "validity check for halted" do
    conn = %Plug.Conn{halted: true}
    assert conn == NebulaWeb.V1.PutController.validity_check(conn)
  end

  test "validity check for request path" do
    conn = build_conn("PUT", "path/without/trailing/slash")
    new_conn = NebulaWeb.V1.PutController.validity_check(conn)
    assert new_conn.resp_body == "{\"error\":\"Container name must end with a \\\"/\\\"\"}"

    conn = build_conn("PUT", "object/name/cant/start/with/cdmi_/cdmi_object/")
    new_conn = NebulaWeb.V1.PutController.validity_check(conn)
    assert new_conn.resp_body == "{\"error\":\"Container name must must not start with \\\"cdmi_\\\"\"}"

    conn = build_conn("PUT", "this/is/a/good/path/")
    new_conn = NebulaWeb.V1.PutController.validity_check(conn)
    assert new_conn == conn
  end
end
