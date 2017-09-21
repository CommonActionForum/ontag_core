defmodule OntagCoreWeb.QuestionController do
  use OntagCoreWeb, :controller
  alias OntagCore.QAMS

  plug OntagCoreWeb.Authentication when action in [:create]
  action_fallback OntagCoreWeb.FallbackController

  def create(conn, params) do
    author = QAMS.ensure_author_exists(conn.assigns[:current_user])

    with {:ok, question} <- QAMS.create_question(author, params) do
      conn
      |> put_status(:created)
      |> json(%{id: question.id})
    end
  end

  def index(conn, _) do
    questions =
      QAMS.list_questions()
      |> Enum.map(fn question -> %{id: question.id, title: question.title} end)

    conn
    |> put_status(:ok)
    |> json(questions)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, question} <- QAMS.get_question(id) do
      conn
      |> put_status(:ok)
      |> json(%{id: question.id, title: question.title})
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, _} <- QAMS.delete_question(id) do
      conn
      |> put_status(:ok)
      |> json(%{message: "Question successfully deleted"})
    end
  end
end
