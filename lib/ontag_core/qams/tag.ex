defmodule OntagCore.QAMS.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias OntagCore.QAMS.{Tag,
                        Author,
                        Annotation}

  schema "tags" do
    field :title, :string
    belongs_to :author, Author
    has_many :annotations, Annotation

    timestamps()
  end

  def changeset(%Tag{} = tag, attrs) do
    tag
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
