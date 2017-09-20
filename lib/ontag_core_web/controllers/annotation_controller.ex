defmodule OntagCoreWeb.AnnotationController do
  use OntagCoreWeb, :controller
  alias OntagCore.QAMS

  plug OntagCoreWeb.Authentication when action in [:create]
  action_fallback OntagCoreWeb.FallbackController

  def create(conn, params) do
    author = QAMS.ensure_author_exists(conn.assigns[:current_user])

    with {:ok, annotation} <- QAMS.create_annotation(author, params) do
      conn
      |> put_status(:created)
      |> json(%{id: annotation.id})
    end
  end
end
