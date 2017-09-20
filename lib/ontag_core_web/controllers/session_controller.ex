defmodule OntagCoreWeb.SessionController do
  use OntagCoreWeb, :controller
  alias OntagCore.Accounts
  alias OntagCore.Guardian

  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_with_password_credential(email, password) do
      {:ok, user} ->
        {:ok, token, claims} = Guardian.encode_and_sign(user)

        conn
        |> put_status(:created)
        |> put_resp_header("authorization", "Bearer #{token}")
        |> json(%{access_token: token})

      {:error, _} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{message: "Given e-mail or password is wrong"})
    end
  end

  def create(conn, _) do
    conn
    |> put_status(:bad_request)
    |> json(%{message: "Wrong request. The required parameters are `email` and `password`"})
  end
end
