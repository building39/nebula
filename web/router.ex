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
      resources "/cdmi_object", CdmiObjectController, only: [:show]
      resources "/container", ContainerController, except: [:new, :edit]
      resources "/dataobject", DataobjectController, except: [:new, :edit]
    end
  end
end
