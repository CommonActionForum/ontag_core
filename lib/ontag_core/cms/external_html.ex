defmodule OntagCore.CMS.ExternalHTML do
  use Ecto.Schema
  import Ecto.Changeset
  alias OntagCore.CMS.{ExternalHTML,
                       Entry}

  schema "external_htmls" do
    field :uri, :string
    belongs_to :entry, Entry

    timestamps()
  end

  def changeset(%ExternalHTML{} = html, attrs) do
    html
    |> cast(attrs, [:uri])
    |> validate_required([:uri])
  end
end
