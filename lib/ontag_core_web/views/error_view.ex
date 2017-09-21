defmodule OntagCoreWeb.ErrorView do
  use OntagCoreWeb, :view

  def render("404.html", _assigns) do
    "Page not found"
  end

  def render("500.html", _assigns) do
    "Internal server error"
  end

  def render("400.json", _assigns) do
    %{
      message: "Bad request"
    }
  end

  def render("401.json", _assigns) do
    %{
      message: "Authentication required. Log in to perform this action"
    }
  end

  def render("403.json", _assigns) do
    %{
      message: "You are not allowed to perform this action"
    }
  end

  def render("404.json", _assigns) do
    %{
      message: "Resource not found"
    }
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end
end
