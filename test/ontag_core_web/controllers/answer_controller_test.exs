defmodule OntagCoreWeb.AnswerControllerTest do
  use OntagCoreWeb.ConnCase
  alias OntagCore.{QAMS,
                   Accounts,
                   Guardian}

  test "POST /answers without a valid authorization header" do
    conn =
      build_conn()
      |> put_req_header("authorization", "none")
      |> post(answer_path(build_conn(), :create, %{}))

    assert json_response(conn, :unauthorized)
  end

  test "POST /answers with a non-valid token" do
    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer none")
      |> post(answer_path(build_conn(), :create, %{}))

    assert json_response(conn, :unauthorized)
  end

  test "POST /answers with wrong parameters" do
    {:ok, user} = Accounts.create_user(%{username: "john"})
    {:ok, token, _} = Guardian.encode_and_sign(user)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post(answer_path(build_conn(), :create, %{}))

    assert json_response(conn, :bad_request)
  end

  test "POST /answers with right parameters" do
    {:ok, user} = Accounts.create_user(%{username: "john"})
    {:ok, token, _} = Guardian.encode_and_sign(user)
    cms_author = OntagCore.CMS.ensure_author_exists(user)
    {:ok, entry} = OntagCore.CMS.create_entry(cms_author, %{title: "Example entry"})
    qams_author = QAMS.ensure_author_exists(user)
    {:ok, tag1} = QAMS.create_tag(qams_author, %{title: "Tag 1"})
    {:ok, q1} = QAMS.create_question(qams_author, %{title: "Tag 1"})

    annotations_params = %{
      tag_id: tag1.id,
      entry_id: entry.id,
      target: %{something: ""}
    }
    {:ok, a1} = QAMS.create_annotation(qams_author, annotations_params)
    {:ok, a2} = QAMS.create_annotation(qams_author, annotations_params)

    answer_params = %{
      question_id: q1.id,
      annotations: [a1.id, a2.id]
    }

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post(answer_path(build_conn(), :create, answer_params))

    assert json_response(conn, :created)
  end
end
