defmodule Nebula.Constants do
  @moduledoc """
  Define system-wide constants here.
  """

  defmacro api_prefix do
    "/api/v1/"
  end

  defmacro capabilities_object do
    "application/cdmi-capabilities"
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

  defmacro system_capabilities_uri do
    "/cdmi_capabilities/"
  end

  defmacro system_domain_uri do
    "/cdmi_domains/system_domain/"
  end

end
