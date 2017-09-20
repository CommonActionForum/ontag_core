defmodule OntagCore.AccountsTest do
  use OntagCore.DataCase
  alias OntagCore.Accounts
  alias OntagCore.Accounts.{User,
                            PasswordCredential}
  @moduledoc """
  Test for `OntagCore.Accounts`
  """

  test "Create a user without credentials successfully" do
    params = %{
      username: "john_example",
      name: "John example"
    }

    assert {:ok, user} = Accounts.create_user(params)
    assert user.username == "john_example"
  end

  test "Create a user with a PasswordCredential successfully" do
    params = %{
      username: "john_example",
      name: "John example",
      password_credential: %{
        email: "john@example.com",
        password: "1234"
      }
    }

    assert {:ok, %User{} = user} = Accounts.create_user(params)
    assert user.username == "john_example"
  end

  test "Get password credential given its e-mail" do
    params = %{
      username: "john_example",
      name: "John example",
      password_credential: %{
        email: "john@example.com",
        password: "1234"
      }
    }

    assert {:ok, _} = Accounts.create_user(params)
    assert {:ok, %PasswordCredential{}} =
      Accounts.get_password_credential_from_email("john@example.com")
  end

  test "Check password validity" do
    params = %{
      username: "john_example",
      name: "John example",
      password_credential: %{
        email: "john@example.com",
        password: "1234"
      }
    }

    assert {:ok, _} = Accounts.create_user(params)
    assert {:ok, %PasswordCredential{} = pc} =
      Accounts.get_password_credential_from_email("john@example.com")
    assert {:ok, pc} == Accounts.check_password({:ok, pc}, "1234")
  end

  test "Get user from PasswordCredential" do
    params = %{
      username: "john_example",
      name: "John example",
      password_credential: %{
        email: "john@example.com",
        password: "1234"
      }
    }

    assert {:ok, user} = Accounts.create_user(params)
    assert {:ok, %PasswordCredential{} = pc} =
      Accounts.get_password_credential_from_email("john@example.com")
    assert {:ok, user2} = Accounts.get_user_from_password_credential({:ok, pc})

    assert Map.drop(user, [:password_credential]) ==
      Map.drop(user2, [:password_credential])
  end

  test "Authenticate a user" do
    params = %{
      username: "john_example",
      name: "John example",
      password_credential: %{
        email: "john@example.com",
        password: "1234"
      }
    }

    assert {:ok, user} = Accounts.create_user(params)
    assert {:ok, user2} =
      Accounts.authenticate_with_password_credential("john@example.com", "1234")

    assert Map.drop(user, [:password_credential]) ==
      Map.drop(user2, [:password_credential])
  end

  test "Fail to create a duplicated user (same username)" do
    params = %{
      username: "john_example",
      name: "John example"
    }

    assert {:ok, _} = Accounts.create_user(params)
    assert {:error, changeset} = Accounts.create_user(params)
    assert %{username: ["has already been taken"]} = errors_on(changeset)
  end

  test "Fail to create a user with a PasswordCredential (same email)" do
    credential = %{
      email: "john@example.com",
      password: "1234"
    }

    params = %{
      username: "john_example",
      name: "John example",
      password_credential: credential
    }

    params2 = %{
      username: "maria_example",
      name: "Maria example",
      password_credential: credential
    }

    assert {:ok, _} = Accounts.create_user(params)
    assert {:error, changeset} = Accounts.create_user(params2)
    assert %{
      password_credential: %{
        email: ["has already been taken"]
      }
    } = errors_on(changeset)
  end

  test "Fail to authenticate a user (e-mail not found)" do
    params = %{
      username: "john_example",
      name: "John example",
      password_credential: %{
        email: "john@example.com",
        password: "1234"
      }
    }

    assert {:ok, _} = Accounts.create_user(params)
    assert {:error, :unauthorized} ==
      Accounts.authenticate_with_password_credential("maria@example.com", "1234")
  end

  test "Fail to authenticate a user (password do not match)" do
    params = %{
      username: "john_example",
      name: "John example",
      password_credential: %{
        email: "john@example.com",
        password: "1234"
      }
    }

    assert {:ok, _} = Accounts.create_user(params)
    assert {:error, :unauthorized} ==
      Accounts.authenticate_with_password_credential("john@example.com", "12345")
  end
end
