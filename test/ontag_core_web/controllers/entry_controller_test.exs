defmodule OntagCoreWeb.EntryControllerTest do
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

    author = create_test_cms_author(user)
    entry = create_test_entry(author)

    world = %{
      wrong_header: wrong_header,
      wrong_token: wrong_token,
      valid_token: valid_token,
      entry: entry
    }

    {:ok, world}
  end

  test "POST /entries with wrong parameters", %{valid_token: conn} do
    conn = post(conn, entry_path(build_conn(), :create, %{}))
    assert json_response(conn, :unprocessable_entity)
  end

  test "POST /entries with right parameters", %{valid_token: conn} do
    params = %{
      title: "example",
      entry_type: "medium_post",
      medium_post: %{
        title: "example",
        uri: "http://example.com",
        license: "copyright",
        tags: ["some"],
        copyright_cesion: true
      }
    }

    conn = post(conn, entry_path(build_conn(), :create, params))
    assert json_response(conn, :created)
  end

  test "GET /entries" do
    conn = get(build_conn(), entry_path(build_conn(), :index, %{}))
    assert json_response(conn, :ok)
  end

  test "GET /entries/:id with an existing entry", %{entry: entry} do
    conn = get(build_conn(), entry_path(build_conn(), :show, entry.id))
    assert json_response(conn, :ok)
  end

  test "GET /entries/:id with a non-existing entry", %{} do
    conn = get(build_conn(), entry_path(build_conn(), :show, 0))
    assert json_response(conn, :not_found)
  end

  test "DELETE /entries/:id with an existing entry", %{entry: entry} do
    conn = delete(build_conn(), entry_path(build_conn(), :delete, entry.id))
    assert json_response(conn, :ok)
  end

  test "DELETE /entries/:id with a non-existing entry", %{} do
    conn = delete(build_conn(), entry_path(build_conn(), :delete, 0))
    assert json_response(conn, :not_found)
  end
end
