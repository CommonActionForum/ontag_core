defmodule OntagCoreWeb.PageController do
  use OntagCoreWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
