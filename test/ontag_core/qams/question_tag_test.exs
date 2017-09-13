defmodule OntagCore.QAMS.QuestionTagTest do
  use OntagCore.DataCase
  alias OntagCore.QAMS.QuestionTag
  @moduledoc """
  Tests for `OntagCore.QAMS.QuestionTag`
  """

  test "Valid data on changeset" do
    params = %{
      question_id: 0,
      tag_id: 0,
      required: false
    }

    changeset = QuestionTag.changeset(%QuestionTag{}, params)
    assert changeset.valid?
  end

  test "Invalid data on changeset: no 'required'" do
    params = %{
      question_id: 0,
      tag_id: 0
    }

    changeset = QuestionTag.changeset(%QuestionTag{}, params)
    assert %{required: ["can't be blank"]} = errors_on(changeset)
  end
end
