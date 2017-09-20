defmodule OntagCoreWeb.SessionControllerTest do
  use OntagCoreWeb.ConnCase
  alias OntagCore.Accounts

  test "POST /sessions with valid parameters" do
    # Create example user
    user = %{
      username: "john",
      password_credential: %{
        email: "john@example.com",
        password: "12345"
      }
    }

    Accounts.create_user(user)

    params = %{
      "email": "john@example.com",
      "password": "12345"
    }

    response =
      build_conn()
      |> post(session_path(build_conn(), :create, params))
      |> json_response(:created)

    assert %{"access_token" => _} = response
  end

  test "POST /sessions with a non-existent user" do
    params = %{
      "email": "john@non-existent.com",
      "password": "12345"
    }

    conn =
      build_conn()
      |> post(session_path(build_conn(), :create, params))

    assert json_response(conn, :unauthorized)
  end

  test "POST /sessions with wrong parameters" do
    params = %{
      "password": "12345"
    }

    conn =
      build_conn()
      |> post(session_path(build_conn(), :create, params))

    assert json_response(conn, :bad_request)
  end
end
