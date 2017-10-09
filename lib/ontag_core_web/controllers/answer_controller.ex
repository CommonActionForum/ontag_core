defmodule OntagCoreWeb.AnswerController do
  use OntagCoreWeb, :controller
  alias OntagCore.QAMS
  alias OntagCore.Repo

  plug OntagCoreWeb.Authentication when action in [:create, :add_annotation, :remove_annotation]
  action_fallback OntagCoreWeb.FallbackController

  def create(conn, params) do
    author = QAMS.ensure_author_exists(conn.assigns[:current_user])

    with {:ok, answer} <- QAMS.create_answer(author, params) do
      conn
      |> put_status(:created)
      |> json(%{id: answer.id,
                question_id: answer.question_id})
    end
  end

  def index(conn, _) do
    answers =
      QAMS.list_answers()
      |> Repo.preload(:annotations)
      |> Enum.map(fn answer -> %{id: answer.id,
                                 question_id: answer.question_id,
                                 annotations: take(answer.annotations)} end)

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

  def add_annotation(conn, %{"answer_id" => id, "annotation_id" => annotation_id}) do
    author = QAMS.ensure_author_exists(conn.assigns[:current_user])

    with {:ok, _} <- QAMS.add_annotation_to_answer(author, id, annotation_id) do
      conn
      |> put_status(:ok)
      |> json(%{message: "Annotation successfully added"})
    end
  end

  def remove_annotation(conn, %{"answer_id" => id, "annotation_id" => annotation_id}) do
    author = QAMS.ensure_author_exists(conn.assigns[:current_user])

    with {:ok, _} <- QAMS.remove_annotation_from_answer(id, annotation_id) do
      conn
      |> put_status(:ok)
      |> json(%{message: "Annotation successfully removed"})
    end
  end


  defp take(annotations) do
    Enum.map(annotations, fn a -> %{id: a.id,
                                    tag_id: a.tag_id,
                                    entry_id: a.entry_id,
                                    target: a.target} end)
  end
end
