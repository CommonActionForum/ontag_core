defmodule OntagCoreWeb.TagControllerTest do
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

    world = %{
      wrong_header: wrong_header,
      wrong_token: wrong_token,
      valid_token: valid_token
    }

    {:ok, world}
  end

  test "POST /tags without a valid authorization header", %{wrong_header: conn} do
    conn = post(conn, tag_path(build_conn(), :create, %{}))
    assert json_response(conn, :unauthorized)
  end

  test "POST /tags with a non-valid token", %{wrong_token: conn} do
    conn = post(conn, tag_path(build_conn(), :create, %{}))
    assert json_response(conn, :unauthorized)
  end

  test "POST /tags with wrong parameters", %{valid_token: conn} do
    conn = post(conn, tag_path(build_conn(), :create, %{}))
    assert json_response(conn, :unprocessable_entity)
  end

  test "POST /tags with right parameters", %{valid_token: conn} do
    params = %{
      title: "Example tag"
    }
    conn = post(conn, tag_path(build_conn(), :create, params))
    assert json_response(conn, :created)
  end

  test "GET /tags" do
    conn = get(build_conn(), tag_path(build_conn(), :index))
    assert json_response(conn, :ok)
  end

  test "GET /tags/:id with non-existent id" do
    conn = get(build_conn(), tag_path(build_conn(), :show, 0))
    assert json_response(conn, :not_found)
  end

  test "DELETE /tags/:id with non-existent id" do
    conn = delete(build_conn(), tag_path(build_conn(), :delete, 0))
    assert json_response(conn, :not_found)
  end
end
