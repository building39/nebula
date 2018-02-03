defmodule Noecto.V1.ContainerControllerTest do
  use Noecto.ConnCase

  alias Noecto.Container
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "the truth" do
    assert 1 + 1 == 2
  end
end
