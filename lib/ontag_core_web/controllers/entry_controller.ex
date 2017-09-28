defmodule OntagCoreWeb.EntryController do
  use OntagCoreWeb, :controller
  alias OntagCore.CMS

  plug OntagCoreWeb.Authentication when action in [:create]
  action_fallback OntagCoreWeb.FallbackController

  def create(conn, params) do
    author = CMS.ensure_author_exists(conn.assigns[:current_user])

    with {:ok, entry} <- CMS.create_entry(author, params) do
      conn
      |> put_status(:created)
      |> json(%{id: entry.id})
    end
  end

  def index(conn, _) do
    entries =
      CMS.list_entries()
      |> Enum.map(fn entry -> %{id: entry.id, title: entry.title} end)

    conn
    |> put_status(:ok)
    |> json(entries)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, entry} <- CMS.get_entry(id) do
      conn
      |> put_status(:ok)
      |> json(%{id: entry.id, title: entry.title})
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, entry} <- CMS.delete_entry(id) do
      conn
      |> put_status(:ok)
      |> json(%{id: entry.id, title: entry.title})
    end
  end
end
