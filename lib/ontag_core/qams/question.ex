defmodule OntagCore.QAMS.Question do
  use Ecto.Schema
  import Ecto.Changeset
  alias OntagCore.QAMS.{Question,
                        Author,
                        Tag,
                        QuestionTag}

  schema "questions" do
    field :title, :string
    field :required_tags, {:array, :id}, virtual: true
    field :optional_tags, {:array, :id}, virtual: true
    belongs_to :author, Author
    many_to_many :tags, Tag, join_through: QuestionTag

    timestamps()
  end

  def changeset(%Question{} = question, attrs) do
    question
    |> cast(attrs, [:title, :required_tags, :optional_tags])
    |> validate_required([:title])
  end
end
