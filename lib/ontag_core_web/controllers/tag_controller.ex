defmodule OntagCoreWeb.TagController do
  use OntagCoreWeb, :controller
  alias OntagCore.QAMS

  plug :put_user_from_token when action in [:create]

  def create(conn, params) do
    result =
      QAMS.ensure_author_exists(conn.assigns[:current_user])
      |> QAMS.create_tag(params)

    case result do
      {:ok, tag} ->
        conn
        |> put_status(:created)
        |> json(%{id: tag.id})

      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{message: "Something go wrong"})
    end
  end

  def index(conn, _) do
    tags =
      QAMS.list_tags()
      |> Enum.map(fn tag -> %{id: tag.id, title: tag.title} end)

    conn
    |> put_status(:ok)
    |> json(tags)
  end

  def show(conn, %{"id" => id}) do
    case QAMS.get_tag(id) do
      {:ok, tag} ->
        conn
        |> put_status(:ok)
        |> json(%{id: tag.id, title: tag.title})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{message: "Resource not found"})
    end
  end

  def delete(conn, %{"id" => id}) do
    case QAMS.delete_tag(id) do
      {:ok, tag} ->
        conn
        |> put_status(:ok)
        |> json(%{message: "Tag successfully deleted"})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{message: "Resource not found"})
    end
  end

  def update(conn, params = %{"id" => id}) do
    case QAMS.update_tag(id, params) do
      {:ok, tag} ->
        conn
        |> put_status(:ok)
        |> json(%{id: tag.id, title: tag.title})

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
