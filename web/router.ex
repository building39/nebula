defmodule Nebula.Router do
  use Nebula.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Nebula do
    pipe_through :api
    scope "/v1", V1, as: :v1 do
      resources "/container", ContainerController, except: [:new, :edit]
      resources "/dataobject", DataobjectController, except: [:new, :edit]
    end
  end
end
