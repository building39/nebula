defmodule NebulaWeb.Router do
  use NebulaWeb, :router

  pipeline :api do
    plug(:accepts, ["json", "cdmia", "cdmic", "cdmid", "cdmio", "cdmiq"])
    plug(NebulaWeb.Plugs.V1.CDMIVersion)
    plug(NebulaWeb.Plugs.V1.ResolveDomain)
    plug(NebulaWeb.Plugs.V1.ApplyCapabilities)
    plug(NebulaWeb.Plugs.V1.Authentication)
    plug(NebulaWeb.Plugs.V1.Prefetch)
    # plug NebulaWeb.Plugs.V1.CheckDomain
    # plug NebulaWeb.Plugs.V1.ApplyACLs
  end

  scope "/cdmi", NebulaWeb do
    pipe_through(:api)

    scope "/v1", V1, as: :v1 do
      # get("/cdmi_objectid/:id", CdmiObjectController, :show)
      get("/", GetController, :show)
      get("/*path", GetController, :show)
      # delete("/cdmi_objectid/:id", CdmiObjectController, :delete)
      # delete("/cdmi_domains/*path", DomainController, :delete)
      delete("/*path", PutController, :delete)
      # put("/container/*path", PutController, :create)
      # put("/cdmi_domains/*path", DomainController, :create)
      post("/", PostController, :update)
      post("/*path", PostController, :update)
      put("/", PutController, :create)
      put("/*path", PutController, :create)
    end
  end
end
