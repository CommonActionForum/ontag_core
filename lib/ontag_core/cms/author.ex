defmodule OntagCore.CMS.Author do
  use Ecto.Schema
  import Ecto.Changeset
  alias OntagCore.CMS.{Author,
                       Entry}
  @moduledoc """
  Schema for Author
  """

  schema "cms_authors" do
    field :role, :string
    has_many :entries, Entry
    belongs_to :user, OntagCore.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(%Author{} = author, attrs) do
    author
    |> cast(attrs, [:role])
    |> validate_required([:role])
    |> validate_inclusion(:role, ["writer", "admin"])
  end
end
