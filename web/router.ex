defmodule Nebula.Router do
  use Nebula.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Nebula.V1.CDMIVersion
    plug Nebula.V1.ResolveDomain
    plug Nebula.V1.ApplyCapabilities
    plug Nebula.V1.Authentication
    plug Nebula.V1.Prefetch
    #plug Nebula.V1.CheckDomain
    #plug Nebula.V1.ApplyACLs
  end

  scope "/api", Nebula do
    pipe_through :api
    scope "/v1", V1, as: :v1 do
      get "/cdmi_objectid/:id", CdmiObjectController, :show
      get "/cdmi_capabilities/*path", CapabilitiesController, :show
      delete "/container/*path", ContainerController, :delete
      delete "/cdmi_objectid/:id", CdmiObjectController, :delete
      get "/container", ContainerController, :show
      get "/container/*path", ContainerController, :show
      put "/container/*path", ContainerController, :create
      get "/cdmi_domains/*path", DomainController, :show
    end
  end
end
