defmodule OntagCoreWeb.EntryControllerTest do
  use OntagCoreWeb.ConnCase
  alias OntagCore.{Accounts,
                   Guardian}

  test "POST /entries without a valid authorization header" do
    conn =
      build_conn()
      |> put_req_header("authorization", "none")
      |> post(entry_path(build_conn(), :create, %{}))

    assert json_response(conn, :unauthorized)
  end

  test "POST /entries with a non-valid token" do
    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer none")
      |> post(entry_path(build_conn(), :create, %{}))

    assert json_response(conn, :unauthorized)
  end

  test "POST /entries with wrong parameters" do
    {:ok, user} = Accounts.create_user(%{username: "john"})
    {:ok, token, _} = Guardian.encode_and_sign(user)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post(entry_path(build_conn(), :create, %{}))

    assert json_response(conn, :bad_request)
  end

  test "POST /entries with right parameters" do
    {:ok, user} = Accounts.create_user(%{username: "john"})
    {:ok, token, _} = Guardian.encode_and_sign(user)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post(entry_path(build_conn(), :create, %{title: "example"}))

    assert json_response(conn, :created)
  end
end
