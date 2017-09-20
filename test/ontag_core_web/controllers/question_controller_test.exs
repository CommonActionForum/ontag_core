defmodule OntagCoreWeb.QuestionControllerTest do
  use OntagCoreWeb.ConnCase
  alias OntagCore.{Accounts,
                   Guardian}

  test "POST /questions without a valid authorization header" do
    conn =
      build_conn()
      |> put_req_header("authorization", "none")
      |> post(question_path(build_conn(), :create, %{}))

    assert json_response(conn, :unauthorized)
  end

  test "POST /questions with a non-valid token" do
    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer none")
      |> post(question_path(build_conn(), :create, %{}))

    assert json_response(conn, :unauthorized)
  end

  test "POST /questions with wrong parameters" do
    {:ok, user} = Accounts.create_user(%{username: "john"})
    {:ok, token, _} = Guardian.encode_and_sign(user)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post(question_path(build_conn(), :create, %{}))

    assert json_response(conn, :bad_request)
  end

  test "POST /questions with right parameters" do
    {:ok, user} = Accounts.create_user(%{username: "john"})
    {:ok, token, _} = Guardian.encode_and_sign(user)

    params = %{
      title: "Example question",
      required_tags: [],
      optional_tags: []
    }

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post(question_path(build_conn(), :create, params))

    assert json_response(conn, :created)
  end

  test "GET /questions" do
    conn =
      build_conn()
      |> get(question_path(build_conn(), :index))

    assert json_response(conn, :ok)
  end

  test "GET /tags/:id with non-existent id" do
    conn =
      build_conn()
      |> get(question_path(build_conn(), :show, 0))

    assert json_response(conn, :not_found)
  end
end
