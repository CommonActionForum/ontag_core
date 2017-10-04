defmodule OntagCoreWeb.EntryController do
  use OntagCoreWeb, :controller
  alias OntagCore.CMS
  alias OntagCore.Repo

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
      |> Repo.preload(:medium_post)
      |> Repo.preload(:external_html)
      |> Enum.map(&take/1)

    conn
    |> put_status(:ok)
    |> json(entries)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, entry} <- CMS.get_entry(id) do
      entry = take(entry)

      conn
      |> put_status(:ok)
      |> json(entry)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, entry} <- CMS.delete_entry(id) do
      conn
      |> put_status(:ok)
      |> json(%{id: entry.id, title: entry.title})
    end
  end

  defp take(entry) do
    base = %{
      id: entry.id,
      title: entry.title,
      entry_type: entry.entry_type
    }

    extra =
      case entry.entry_type do
        "medium_post" ->
          %{medium_post: %{title: entry.medium_post.title,
                           uri: entry.medium_post.uri}}

        "external_html" ->
          %{}
      end

    Map.merge(base, extra)
  end
end
