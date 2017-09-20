defmodule OntagCore.QAMS.AnnotationTest do
  use OntagCore.DataCase
  alias OntagCore.QAMS.Annotation
  @moduledoc """
  Tests for `OntagCore.QAMS.Annotation`
  """

  test "Valid data on changeset" do
    params = %{
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
