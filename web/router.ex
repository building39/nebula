defmodule Nebula.Router do
  use Nebula.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Nebula.CDMIVersion
    plug Nebula.Authentication
  end

  scope "/api", Nebula do
    pipe_through :api
    scope "/v1", V1, as: :v1 do
      get "/cdmi_object/:id", ContainerController, :show
      get "/container", ContainerController, :show
      get "/container/*path", ContainerController, :show
    end
  end
end
