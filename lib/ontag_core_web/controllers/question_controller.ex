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
      QAMS.list_tags()
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
end
