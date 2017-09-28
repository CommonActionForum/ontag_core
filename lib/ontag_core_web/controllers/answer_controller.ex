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

  def index(conn, _) do
    answers =
      QAMS.list_answers()
      |> Enum.map(fn answer -> %{id: answer.id} end)

    conn
    |> put_status(:ok)
    |> json(answers)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, answer} <- QAMS.get_answer(id) do
      conn
      |> put_status(:ok)
      |> json(%{id: answer.id})
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, _tag} <- QAMS.delete_answer(id) do
      conn
      |> put_status(:ok)
      |> json(%{message: "Tag successfully deleted"})
    end
  end
end
