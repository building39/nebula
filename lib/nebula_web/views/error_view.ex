defmodule NebulaWeb.ErrorView do
  use NebulaWeb, :view

  def render("404.json", _assigns) do
    %{errors: %{detail: "Page not found"}}
  end

  def render("404.cdmia", _assigns) do
    %{errors: %{detail: "Capability not found"}}
  end

  def render("404.cdmic", _assigns) do
    %{errors: %{detail: "Container not found"}}
  end

  def render("404.cdmid", _assigns) do
    %{errors: %{detail: "Domain not found"}}
  end

  def render("404.cdmio", _assigns) do
    %{errors: %{detail: "Object not found"}}
  end

  def render("404.cdmiq", _assigns) do
    %{errors: %{detail: "Queue not found"}}
  end

  def render("406.cdmic", _assigns) do
    %{errors: %{detail: "Container not acceptable"}}
  end

  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal server error"}}
  end
  def render("500.cdmia", _assigns) do
    %{errors: %{detail: "Internal server error"}}
  end

  def render("500.cdmic", _assigns) do
    %{errors: %{detail: "Internal server error"}}
  end

  def render("500.cdmid", _assigns) do
    %{errors: %{detail: "Internal server error"}}
  end

  def render("500.cdmio", _assigns) do
    %{errors: %{detail: "Internal server error"}}
  end

  def render("500.cdmiq", _assigns) do
    %{errors: %{detail: "Internal server error"}}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render("500.json", assigns)
  end
end
