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
end
