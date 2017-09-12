defmodule OntagCore.Accounts.PasswordCredentialTest do
  use OntagCore.DataCase
  alias OntagCore.Accounts.PasswordCredential
  @moduledoc """
  Tests for `OntagCore.Accounts.PasswordCredential`
  """

  test "Valid data on changeset" do
    params = %{
      email: "john@example.com",
      password: "secret"
    }

    changeset = PasswordCredential.changeset(%PasswordCredential{}, params)
    assert changeset.valid?
    assert %{encrypted_password: _} = changeset.changes
  end

  test "Invalid data on changeset: no email" do
    params = %{
      password: "secret"
    }

    changeset = PasswordCredential.changeset(%PasswordCredential{}, params)
    assert %{email: ["can't be blank"]} = errors_on(changeset)
  end

  test "Invalid data on changeset: no password" do
    params = %{
      email: "john@example.com",
    }

    changeset = PasswordCredential.changeset(%PasswordCredential{}, params)
    assert %{password: ["can't be blank"]} = errors_on(changeset)
  end

  test "Invalid data on changeset: invalid email" do
    params = %{
      email: "john",
    }

    changeset = PasswordCredential.changeset(%PasswordCredential{}, params)
    assert %{email: ["has invalid format"]} = errors_on(changeset)
  end
end
