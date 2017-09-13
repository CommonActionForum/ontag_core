defmodule OntagCore.QAMS.AnswerAnnotation do
  use Ecto.Schema
  import Ecto.Changeset
  alias OntagCore.QAMS.{AnswerAnnotation,
                        Answer,
                        Annotation}

  schema "answers_annotations" do
    belongs_to :answer, Answer
    belongs_to :annotation, Annotation

    timestamps()
  end

  def changeset(%AnswerAnnotation{} = annotation, attrs) do
    annotation
    |> cast(attrs, [:answer_id, :annotation_id])
    |> validate_required([:answer_id, :annotation_id])
  end
end
