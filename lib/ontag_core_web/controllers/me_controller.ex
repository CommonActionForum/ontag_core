defmodule OntagCoreWeb.MeController do
  use OntagCoreWeb, :controller

  plug OntagCoreWeb.Authentication when action in [:index]
  action_fallback OntagCoreWeb.FallbackController

  def index(conn, _) do
    user =
      conn.assigns[:current_user]

    conn
    |> put_status(:ok)
    |> json(
      %{
        id: user.id,
        name: user.name,
        username: user.username
      }
    )
  end
end
