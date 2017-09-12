defmodule OntagCore.CMS.AuthorTest do
  use OntagCore.DataCase
  alias OntagCore.CMS.Author
  @moduledoc """
  Tests for `OntagCore.CMS.Author`
  """

  test "Valid data on changeset" do
    params = %{
      role: "writer"
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
