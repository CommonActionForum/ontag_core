defmodule OntagCoreWeb.AnnotationController do
  use OntagCoreWeb, :controller
  alias OntagCore.QAMS

  plug :put_user_from_token

  def create(conn, params) do
    result =
      QAMS.ensure_author_exists(conn.assigns[:current_user])
      |> QAMS.create_annotation(params)

    case result do
      {:ok, annotation} ->
        conn
        |> put_status(:created)
        |> json(%{id: annotation.id})

      {:error, e} ->
        conn
        |> put_status(:bad_request)
        |> json(%{message: "Something go wrong"})
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
