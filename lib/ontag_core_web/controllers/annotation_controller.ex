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

  def index(conn, _) do
    annotations =
      QAMS.list_annotations()
      |> Enum.map(fn annotation -> %{id: annotation.id,
                                     target: annotation.target,
                                     tag_id: annotation.tag_id,
                                     entry_id: annotation.entry_id} end)

    conn
    |> put_status(:ok)
    |> json(annotations)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, annotation} <- QAMS.get_annotation(id) do
      conn
      |> put_status(:ok)
      |> json(%{id: annotation.id,
                target: annotation.target,
                tag_id: annotation.tag_id,
                entry_id: annotation.entry_id})
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, _tag} <- QAMS.delete_annotation(id) do
      conn
      |> put_status(:ok)
      |> json(%{message: "Tag successfully deleted"})
    end
  end
end
