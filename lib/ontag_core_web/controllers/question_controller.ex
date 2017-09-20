defmodule OntagCoreWeb.QuestionController do
  use OntagCoreWeb, :controller
  alias OntagCore.QAMS

  plug :put_user_from_token when action in [:create]

  def create(conn, params) do
    result =
      QAMS.ensure_author_exists(conn.assigns[:current_user])
      |> QAMS.create_question(params)

    case result do
      {:ok, question} ->
        conn
        |> put_status(:created)
        |> json(%{id: question.id})

      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{message: "Something go wrong"})
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
    case QAMS.get_question(id) do
      {:ok, question} ->
        conn
        |> put_status(:ok)
        |> json(%{id: question.id, title: question.title})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{message: "Resource not found"})
    end
  end

  defp put_user_from_token(conn, _params) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        case OntagCore.Guardian.resource_from_token(token) do
          {:ok, user, _claims} ->
            conn
            |> assign(:current_user, user)

          _ ->
            conn
            |> put_status(:unauthorized)
            |> json(%{message: "The given token is not valid"})
            |> halt()
        end

      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{message: "An `authorization` header must be provided in the request to perform this operation"})
        |> halt()
    end
  end
end
