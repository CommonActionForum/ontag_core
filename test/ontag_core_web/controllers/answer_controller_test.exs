defmodule OntagCoreWeb.AnswerControllerTest do
  use OntagCoreWeb.ConnCase
  alias OntagCore.Guardian

  setup do
    user = create_test_user()
    {:ok, token, _} = Guardian.encode_and_sign(user)

    valid_token =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")

    author = create_test_qams_author(user)
    entry = create_test_entry()
    tag = create_test_tag(author)
    question = create_test_question(author)
    annotation = create_test_annotation(author, entry, tag)

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
end
