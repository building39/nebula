defmodule Nebula.Constants do
  @moduledoc """
  Define system-wide constants here.
  """

  defmacro api_prefix do
    "/api/v1/"
  end

  defmacro capabilities_object do
    "application/cdmi-capability"
  end

  defmacro container_object do
    "application/cdmi-container"
  end

  defmacro dataobject_object do
    "application/cdmi-dataobject"
  end

  defmacro domain_object do
    "application/cdmi-domain"
  end

  defmacro multipart_mixed do
    "application/cdmi-domain"
  end

  defmacro container_capabilities_uri do
    "/cdmi_capabilities/container/"
  end

  defmacro dataobject_capabilities_uri do
    "/cdmi_capabilities/dataobject/"
  end

  defmacro domain_capabilities_uri do
    "/cdmi_capabilities/domain/"
  end

  defmacro system_capabilities_uri do
    "/cdmi_capabilities/"
  end

  defmacro system_domain_uri do
    "/cdmi_domains/system_domain/"
  end

  defmacro render_object_type do
    [
      {capabilities_object(), "cdmi_capabilities.json"},
      {container_object(), "cdmi_container.json"},
      {dataobject_object(), "_cdmi_dataobject.json"},
      {domain_object(), "cdmi_domain.json"}
    ]
  end

end
