defmodule OntagCore.CMS.Entry do
  use Ecto.Schema
  import Ecto.Changeset
  alias OntagCore.CMS.{Entry,
                       Author,
                       MediumPost,
                       ExternalHTML}

  schema "entries" do
    field :title, :string
    field :entry_type, :string
    has_one :medium_post, MediumPost
    has_one :external_html, ExternalHTML
    belongs_to :author, Author

    timestamps()
  end

  def changeset(%Entry{} = entry, attrs) do
    entry
    |> cast(attrs, [:title, :entry_type])
    |> validate_required([:title])
    |> validate_inclusion(:entry_type, ["external_html", "medium_post"])
  end
end
