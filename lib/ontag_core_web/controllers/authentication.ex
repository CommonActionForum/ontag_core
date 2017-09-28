defmodule OntagCoreWeb.Authentication do
  @behaviour Plug
  use OntagCoreWeb, :controller

  @doc false
  def init(opts), do: opts

  @doc false
  def call(conn, _opts) do
    conn
    |> check_authorization_header()
    |> get_current_user()
  end

  defp check_authorization_header(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        conn
        |> assign(:access_token, token)

      _ ->
        conn
        |> put_status(:unauthorized)
        |> render(OntagCoreWeb.ErrorView, "401.json", %{})
        |> halt()
    end
  end

  defp get_current_user(conn = %{halted: false}) do
    token = conn.assigns[:access_token]

    case OntagCore.Guardian.resource_from_token(token) do
      {:ok, user, _claims} ->
        conn
        |> assign(:current_user, user)

      _ ->
        conn
        |> put_status(:unauthorized)
        |> render(OntagCoreWeb.ErrorView, "401.json", %{})
        |> halt()
    end
  end
  defp get_current_user(conn), do: conn
end
