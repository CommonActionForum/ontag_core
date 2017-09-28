defmodule OntagCoreWeb.AnnotationControllerTest do
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
    tag1 = create_test_tag(qams_author)
    tag2 = create_test_tag(qams_author)
    world = %{
      valid_token: valid_token,
      tags: [tag1, tag2],
      entry: entry
    }

    {:ok, world}
  end

  test "POST /annotations with wrong parameters", %{valid_token: conn} do
    conn = post(conn, annotation_path(build_conn(), :create, %{}))
    assert json_response(conn, :unprocessable_entity)
  end

  test "POST /annotations with right parameters", %{valid_token: conn, tags: [tag1, _], entry: entry} do
    annotation_params = %{
      tag_id: tag1.id,
      entry_id: entry.id,
      target: %{something: ""}
    }

    conn = post(conn, annotation_path(build_conn(), :create, annotation_params))
    assert json_response(conn, :created)
  end

  test "GET /annotations" do
    conn = get(build_conn(), annotation_path(build_conn(), :index))
    assert json_response(conn, :ok)
  end

  test "GET /annotations/:id with non-existent id" do
    conn = get(build_conn(), annotation_path(build_conn(), :show, 0))
    assert json_response(conn, :not_found)
  end

  test "DELETE /annotations/:id with non-existent id" do
    conn = delete(build_conn(), annotation_path(build_conn(), :delete, 0))
    assert json_response(conn, :not_found)
  end
end
