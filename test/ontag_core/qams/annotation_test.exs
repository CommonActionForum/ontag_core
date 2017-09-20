defmodule OntagCore.QAMS.AnnotationTest do
  use OntagCore.DataCase
  alias OntagCore.QAMS.Annotation
  @moduledoc """
  Tests for `OntagCore.QAMS.Annotation`
  """

  test "Valid data on changeset" do
    params = %{
      tag_id: 0,
      entry_id: 0,
      target: %{
        type: "TextQuoteSelector"
      }
    }

    changeset = Annotation.changeset(%Annotation{}, params)
    assert changeset.valid?
  end

  test "Invalid data on changeset: no title" do
    params = %{}

    changeset = Annotation.changeset(%Annotation{}, params)
    assert %{target: ["can't be blank"]} = errors_on(changeset)
  end
end
