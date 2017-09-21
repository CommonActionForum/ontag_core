defmodule OntagCoreWeb.AnswerControllerTest do
  use OntagCoreWeb.ConnCase
  alias OntagCore.Guardian

  setup do
    user = create_test_user()
    {:ok, token, _} = Guardian.encode_and_sign(user)

    valid_token =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")

    qams_author = create_test_qams_author(user)
    cms_author = create_test_cms_author(user)
    entry = create_test_entry(cms_author)
    tag = create_test_tag(qams_author)
    question = create_test_question(qams_author)
    annotation = create_test_annotation(qams_author, entry, tag)

    world = %{
      valid_token: valid_token,
      question: question,
      annotation: annotation
    }

    {:ok, world}
  end

  test "POST /answers with wrong parameters", %{valid_token: conn} do
    conn = post(conn, answer_path(build_conn(), :create, %{}))
    assert json_response(conn, :bad_request)
  end

  test "POST /answers with right parameters", %{valid_token: conn,
                                                annotation: annotation,
                                                question: question} do
    params = %{
      question_id: question.id,
      annotations: [annotation.id]
    }

    conn = post(conn, answer_path(build_conn(), :create, params))
    assert json_response(conn, :created)
  end

  test "GET /answers" do
    conn = get(build_conn(), answer_path(build_conn(), :index))
    assert json_response(conn, :ok)
  end

  test "GET /answers/:id with non-existent id" do
    conn = get(build_conn(), answer_path(build_conn(), :show, 0))
    assert json_response(conn, :not_found)
  end

  test "DELETE /answers/:id with non-existent id" do
    conn = delete(build_conn(), answer_path(build_conn(), :delete, 0))
    assert json_response(conn, :not_found)
  end
end
