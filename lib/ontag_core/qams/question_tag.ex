defmodule OntagCore.QAMS.QuestionTag do
  use Ecto.Schema
  import Ecto.Changeset
  alias OntagCore.QAMS.{QuestionTag,
                        Author,
                        Question,
                        Tag}

  schema "questions_tags" do
    belongs_to :author, Author
    belongs_to :question, Question
    belongs_to :tag, Tag
    field :required, :boolean

    timestamps()
  end

  def changeset(%QuestionTag{} = tag, attrs) do
    tag
    |> cast(attrs, [:question_id, :tag_id, :required])
    |> validate_required([:question_id, :tag_id, :required])
  end
end
