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
      get("/*path", GetController, :show)
      delete("/cdmi_objectid/:id", CdmiObjectController, :delete)
      delete("/cdmi_domains/*path", DomainController, :delete)
      delete("/*path", PutController, :delete)
      put("/container/*path", PutController, :create)
      put("/cdmi_domains/*path", DomainController, :create)
      put("/*path", PutController, :create)
    end
  end
end
