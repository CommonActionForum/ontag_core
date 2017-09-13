defmodule OntagCore.QAMS.TagTest do
  use OntagCore.DataCase
  alias OntagCore.QAMS.Tag
  @moduledoc """
  Tests for `OntagCore.QAMS.Tag`
  """

  test "Valid data on changeset" do
    params = %{
      title: "Example"
    }

    changeset = Tag.changeset(%Tag{}, params)
    assert changeset.valid?
  end

  test "Invalid data on changeset: no title" do
    params = %{}

    changeset = Tag.changeset(%Tag{}, params)
    assert %{title: ["can't be blank"]} = errors_on(changeset)
  end
end
