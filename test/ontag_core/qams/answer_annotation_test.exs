defmodule OntagCore.QAMS.AnswerAnnotationTest do
  use OntagCore.DataCase
  alias OntagCore.QAMS.AnswerAnnotation
  @moduledoc """
  Tests for `OntagCore.QAMS.AnswerAnnotation`
  """

  test "Valid data on changeset" do
    params = %{
      answer_id: 0,
      annotation_id: 0
    }

    changeset = AnswerAnnotation.changeset(%AnswerAnnotation{}, params)
    assert changeset.valid?
  end

  test "Invalid data on changeset: no answer_id" do
    params = %{
      annotation_id: 0
    }

    changeset = AnswerAnnotation.changeset(%AnswerAnnotation{}, params)
    assert %{answer_id: ["can't be blank"]} = errors_on(changeset)
  end
end
