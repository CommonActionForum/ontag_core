defmodule OntagCoreWeb.QuestionControllerTest do
  use OntagCoreWeb.ConnCase
  alias OntagCore.Guardian

  setup do
    user = create_test_user()
    {:ok, token, _} = Guardian.encode_and_sign(user)

    wrong_header =
      build_conn()
      |> put_req_header("authorization", "none")

    wrong_token =
      build_conn()
      |> put_req_header("authorization", "Bearer none")

    valid_token =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")

    author = create_test_qams_author(user)
    question = create_test_question(author)

    world = %{
      wrong_header: wrong_header,
      wrong_token: wrong_token,
      valid_token: valid_token,
      question: question
    }

    {:ok, world}
  end

  test "POST /questions without a valid authorization header", %{wrong_header: conn} do
    conn = post(conn, question_path(build_conn(), :create, %{}))
    assert json_response(conn, :unauthorized)
  end

  test "POST /questions with a non-valid token", %{wrong_token: conn} do
    conn = post(conn, question_path(build_conn(), :create, %{}))
    assert json_response(conn, :unauthorized)
  end

  test "POST /questions with wrong parameters", %{valid_token: conn} do
    conn = post(conn, question_path(build_conn(), :create, %{}))
    assert json_response(conn, :unprocessable_entity)
  end

  test "POST /questions with right parameters", %{valid_token: conn} do
    params = %{
      title: "Example question",
      required_tags: [],
      optional_tags: []
    }

    conn = post(conn, question_path(build_conn(), :create, params))
    assert json_response(conn, :created)
  end

  test "GET /questions" do
    conn = get(build_conn(), question_path(build_conn(), :index))
    assert json_response(conn, :ok)
  end

  test "GET /questions/:id with existent id", %{question: question} do
    conn = get(build_conn(), question_path(build_conn(), :show, question.id))
    assert json_response(conn, :ok)
  end

  test "GET /questions/:id with non-existent id" do
    conn = get(build_conn(), question_path(build_conn(), :show, 0))
    assert json_response(conn, :not_found)
  end

  test "DELETE /questions/:id with existent id", %{question: question} do
    conn = delete(build_conn(), question_path(build_conn(), :delete, question.id))
    assert json_response(conn, :ok)
  end

  test "DELETE /questions/:id with non-existent id" do
    conn = delete(build_conn(), question_path(build_conn(), :delete, 0))
    assert json_response(conn, :not_found)
  end
end
