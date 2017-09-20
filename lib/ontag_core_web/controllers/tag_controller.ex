defmodule OntagCoreWeb.TagController do
  use OntagCoreWeb, :controller
  alias OntagCore.QAMS

  plug OntagCoreWeb.Authentication when action in [:create]
  action_fallback OntagCoreWeb.FallbackController

  def create(conn, params) do
    author = QAMS.ensure_author_exists(conn.assigns[:current_user])

    with {:ok, tag} <- QAMS.create_tag(author, params) do
      conn
      |> put_status(:created)
      |> json(%{id: tag.id})
    end
  end

  def index(conn, _) do
    tags =
      QAMS.list_tags()
      |> Enum.map(fn tag -> %{id: tag.id, title: tag.title} end)

    conn
    |> put_status(:ok)
    |> json(tags)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, tag} <- QAMS.get_tag(id) do
      conn
      |> put_status(:ok)
      |> json(%{id: tag.id, title: tag.title})
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, _tag} <- QAMS.delete_tag(id) do
      conn
      |> put_status(:ok)
      |> json(%{message: "Tag successfully deleted"})
    end
  end

  def update(conn, params = %{"id" => id}) do
    with {:ok, tag} <- QAMS.update_tag(id, params) do
      conn
      |> put_status(:ok)
      |> json(%{id: tag.id, title: tag.title})
    end
  end
end
