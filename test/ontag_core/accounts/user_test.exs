defmodule OntagCore.Accounts.UserTest do
  use OntagCore.DataCase
  alias OntagCore.Accounts.User
  @moduledoc """
  Tests for `OntagCore.Accounts.User`
  """

  test "Valid data on changeset" do
    params = %{
      name: "John Example",
      username: "john_example"
    }

    assert %Ecto.Changeset{valid?: true} = User.changeset(%User{}, params)
  end

  test "Invalid data on changeset: no username" do
    params = %{
      name: "John Example"
    }

    changeset = User.changeset(%User{}, params)
    assert %{username: ["can't be blank"]} = errors_on(changeset)
  end

  test "Invalid data on changeset: username too short" do
    params = %{
      username: "_"
    }

    changeset = User.changeset(%User{}, params)
    assert %{username: ["should be at least 2 character(s)"]} = errors_on(changeset)
  end

  test "Invalid data on changeset: username too long" do
    params = %{
      username: "toooooooooooooooooooooooooooolong"
    }

    changeset = User.changeset(%User{}, params)
    assert %{username: ["should be at most 20 character(s)"]} = errors_on(changeset)
  end

  test "Invalid data on changeset: username with wrong format" do
    params = %{
      username: "_  oioe"
    }

    changeset = User.changeset(%User{}, params)
    assert %{username: ["has invalid format"]} = errors_on(changeset)
  end

  test "Username should be case insensitve" do
    ch1 = User.changeset(%User{}, %{username: "john_example"})
    ch2 = User.changeset(%User{}, %{username: "John_Example"})

    assert ch1.changes == ch2.changes
  end
end
