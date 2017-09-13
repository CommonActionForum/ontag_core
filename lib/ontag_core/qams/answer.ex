defmodule OntagCore.QAMS.Answer do
  use Ecto.Schema
  import Ecto.Changeset
  alias OntagCore.QAMS.{Answer,
                        Question,
                        Annotation,
                        AnswerAnnotation}

  schema "answers" do
    belongs_to :question, Question
    many_to_many :annotations, Annotation, join_through: AnswerAnnotation

    timestamps()
  end

  def changeset(%Answer{} = answer, attrs) do
    answer
    |> cast(attrs, [:question_id])
    |> validate_required([:question_id])
  end
end
