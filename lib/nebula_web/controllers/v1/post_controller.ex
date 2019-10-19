defmodule NebulaWeb.V1.PostController do
  @moduledoc """
  Handle cdmi updates
  """

  use NebulaWeb, :controller
  use NebulaWeb.Util.ControllerCommon

  import NebulaWeb.Util.Utils, only: [get_domain_hash: 1]
  require Logger
end
