defmodule OntagCore.QAMS.Annotation do
  use Ecto.Schema
  import Ecto.Changeset
  alias OntagCore.QAMS.{Annotation,
                        Author,
                        Tag,
                        Answer,
                        AnswerAnnotation}

  schema "annotations" do
    belongs_to :author, Author
    belongs_to :tag, Tag
    belongs_to :entry, OntagCore.CMS.Entry
    many_to_many :answers, Answer, join_through: AnswerAnnotation
    field :target, :map

    timestamps()
  end

  def changeset(%Annotation{} = annotation, attrs) do
    annotation
    |> cast(attrs, [:target])
    |> validate_required([:target])
  end
end
