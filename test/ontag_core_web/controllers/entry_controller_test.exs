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

    world = %{
      wrong_header: wrong_header,
      wrong_token: wrong_token,
      valid_token: valid_token
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
end
