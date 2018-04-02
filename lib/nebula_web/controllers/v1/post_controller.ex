defmodule NebulaWeb.V1.PostController do
  @moduledoc """
  Handle cdmi updates
  """

  use NebulaWeb, :controller
  use NebulaWeb.Util.ControllerCommon

  import NebulaWeb.Util.Macros, only: [
    set_mandatory_response_headers: 2
  ]
  import NebulaWeb.Util.Utils, only: [get_domain_hash: 1]
  require Logger

end
