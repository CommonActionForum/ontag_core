defmodule OntagCoreWeb.AnswerController do
  use OntagCoreWeb, :controller
  alias OntagCore.QAMS

  plug OntagCoreWeb.Authentication when action in [:create]
  action_fallback OntagCoreWeb.FallbackController

  def create(conn, params) do
    author = QAMS.ensure_author_exists(conn.assigns[:current_user])

    with {:ok, answer} <- QAMS.create_answer(author, params) do
      conn
      |> put_status(:created)
      |> json(%{id: answer.id})
    end
  end
end
