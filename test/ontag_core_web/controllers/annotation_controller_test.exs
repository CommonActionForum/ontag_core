defmodule OntagCoreWeb.AnnotationControllerTest do
  use OntagCoreWeb.ConnCase
  alias OntagCore.{QAMS,
                   Accounts,
                   Guardian}

  test "POST /annotations without a valid authorization header" do
    conn =
      build_conn()
      |> put_req_header("authorization", "none")
      |> post(annotation_path(build_conn(), :create, %{}))

    assert json_response(conn, :unauthorized)
  end

  test "POST /annotations with a non-valid token" do
    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer none")
      |> post(annotation_path(build_conn(), :create, %{}))

    assert json_response(conn, :unauthorized)
  end

  test "POST /annotations with wrong parameters" do
    {:ok, user} = Accounts.create_user(%{username: "john"})
    {:ok, token, _} = Guardian.encode_and_sign(user)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post(annotation_path(build_conn(), :create, %{}))

    assert json_response(conn, :bad_request)
  end

  test "POST /annotations with right parameters" do
    {:ok, user} = Accounts.create_user(%{username: "john"})
    {:ok, token, _} = Guardian.encode_and_sign(user)
    cms_author = OntagCore.CMS.ensure_author_exists(user)
    {:ok, entry} = OntagCore.CMS.create_entry(cms_author, %{title: "Example entry"})
    qams_author = QAMS.ensure_author_exists(user)
    {:ok, tag1} = QAMS.create_tag(qams_author, %{title: "Tag 1"})

    annotation_params = %{
      tag_id: tag1.id,
      entry_id: entry.id,
      target: %{something: ""}
    }

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post(annotation_path(build_conn(), :create, annotation_params))

    assert json_response(conn, :created)
  end
end
