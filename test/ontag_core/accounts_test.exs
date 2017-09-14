defmodule OntagCore.AccountsTest do
  use OntagCore.DataCase
  alias OntagCore.Accounts
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

    assert {:ok, user} = Accounts.create_user(params)
    assert user.username == "john_example"
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
end
