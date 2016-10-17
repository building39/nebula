defmodule Nebula.Router do
  use Nebula.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Nebula.V1.CDMIVersion
    plug Nebula.V1.Authentication
    plug Nebula.V1.Prefetch
  end

  scope "/api", Nebula do
    pipe_through :api
    scope "/v1", V1, as: :v1 do
      get "/cdmi_object/:id", CdmiObjectController, :show
      get "/container", ContainerController, :show
      get "/container/*path", ContainerController, :show
      put "/container/:path", ContainerController, :create
    end
  end
end
