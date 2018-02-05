defmodule NebulaWeb.Router do
  use NebulaWeb, :router

  pipeline :api do
    plug(:accepts, ["json", "cdmia", "cdmic", "cdmid", "cdmio", "cdmiq"])
    plug(Nebula.V1.CDMIVersion)
    plug(Nebula.V1.ResolveDomain)
    plug(Nebula.V1.ApplyCapabilities)
    plug(Nebula.V1.Authentication)
    plug(Nebula.V1.Prefetch)
    # plug Nebula.V1.CheckDomain
    # plug Nebula.V1.ApplyACLs
  end

  scope "/api", NebulaWeb do
    pipe_through(:api)

    scope "/v1", V1, as: :v1 do
      get("/cdmi_objectid/:id", CdmiObjectController, :show)
      get("/cdmi_capabilities/*path", CapabilitiesController, :show)
      delete("/container/*path", ContainerController, :delete)
      delete("/cdmi_objectid/:id", CdmiObjectController, :delete)
      get("/container", ContainerController, :show)
      get("/container/*path", ContainerController, :show)
      # get "/*path", GetController, :show
      put("/container/*path", ContainerController, :create)
      get("/cdmi_domains/*path", DomainController, :show)
      put("/cdmi_domains/*path", DomainController, :create)
      get("/", ContainerController, :show)
      get("/*path", ContainerController, :show)
      put("/*path", ContainerController, :create)
    end
  end
end
