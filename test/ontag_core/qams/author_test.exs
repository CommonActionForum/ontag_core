defmodule OntagCore.QAMS.AuthorTest do
  use OntagCore.DataCase
  alias OntagCore.QAMS.Author
  @moduledoc """
  Tests for `OntagCore.QAMS.Author`
  """

  test "Valid data on changeset" do
    params = %{
      role: "questioner"
    }

    changeset = Author.changeset(%Author{}, params)
    assert changeset.valid?
  end

  test "Invalid data on changeset: no role" do
    params = %{}

    changeset = Author.changeset(%Author{}, params)
    assert %{role: ["can't be blank"]} = errors_on(changeset)
  end

  test "Invalid data on changeset: invalid role" do
    params = %{
      role: "invalid"
    }

    changeset = Author.changeset(%Author{}, params)
    assert %{role: ["is invalid"]} = errors_on(changeset)
  end
end
