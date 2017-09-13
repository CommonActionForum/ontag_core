defmodule OntagCore.QAMS.Annotation do
  use Ecto.Schema
  import Ecto.Changeset
  alias OntagCore.QAMS.{Annotation,
                        Author,
                        Tag}

  schema "annotations" do
    belongs_to :author, Author
    belongs_to :tag, Tag
    belongs_to :entry, OntagCore.CMS.Entry
    field :target, :map

    timestamps()
  end

  def changeset(%Annotation{} = annotation, attrs) do
    annotation
    |> cast(attrs, [:target])
    |> validate_required([:target])
  end
end
