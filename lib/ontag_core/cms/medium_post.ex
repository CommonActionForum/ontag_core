defmodule OntagCore.CMS.MediumPost do
  use Ecto.Schema
  import Ecto.Changeset
  alias OntagCore.CMS.{MediumPost,
                       Entry}

  schema "medium_posts" do
    field :title, :string
    field :uri, :string
    field :publishing_date, :utc_datetime
    field :license, :string
    field :tags, {:array, :string}
    field :copyright_cesion, :boolean, virtual: true
    belongs_to :entry, Entry

    timestamps()
  end

  def changeset(%MediumPost{} = post, attrs) do
    casted_attrs = [:title, :uri, :publishing_date, :license, :tags,
                    :copyright_cesion]

    required = [:title, :uri, :publishing_date, :tags, :copyright_cesion]
    post
    |> cast(attrs, casted_attrs)
    |> validate_required(required)
    |> validate_acceptance(:copyright_cesion)
  end
end
