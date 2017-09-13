defmodule OntagCore.QAMS.AnswerTest do
  use OntagCore.DataCase
  alias OntagCore.QAMS.Answer
  @moduledoc """
  Tests for `OntagCore.QAMS.Answer`
  """
  test "Valid data on changeset" do
    params = %{
      question_id: 1
    }

    changeset = Answer.changeset(%Answer{}, params)
    assert changeset.valid?
  end

  test "Invalid data on changeset: no title" do
    params = %{}

    changeset = Answer.changeset(%Answer{}, params)
    assert %{question_id: ["can't be blank"]} = errors_on(changeset)
  end
end
