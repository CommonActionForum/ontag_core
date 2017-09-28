defmodule OntagCoreWeb.MeController do
  use OntagCoreWeb, :controller

  plug OntagCoreWeb.Authentication when action in [:index, :add_medium_credential]
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

  def add_medium_credential(conn, %{"state" => state, "code" => code}) do
    with {:ok, user} <- OntagCore.Accounts.login_with_medium(state, code) do
      user = OntagCore.Repo.preload(user, :medium_credential)
      conn
      |> put_status(:ok)
      |> json(
        %{
          medium_id: user.medium_credential.medium_id,
          username: user.medium_credential.username
        }
      )
    end
  end

  def add_medium_credential(conn, _) do
    user = conn.assigns[:current_user]
    state = OntagCore.Accounts.get_medium_login_data(user)

    conn
    |> put_status(:ok)
    |> json(
      %{
        state: state
      }
    )
  end
end
