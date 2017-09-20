defmodule OntagCore.QAMS.QuestionTest do
  use OntagCore.DataCase
  alias OntagCore.QAMS.Question
  @moduledoc """
  Tests for `OntagCore.QAMS.Question`
  """

  test "Valid data on changeset" do
    params = %{
      title: "Example"
    }

    changeset = Question.changeset(%Question{}, params)
    assert changeset.valid?
  end

  test "Invalid data on changeset: no title" do
    params = %{}

    changeset = Question.changeset(%Question{}, params)
    assert %{title: ["can't be blank"]} = errors_on(changeset)
  end
end
