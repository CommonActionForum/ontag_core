defmodule OntagCore.QAMS.Author do
  use Ecto.Schema
  import Ecto.Changeset
  alias OntagCore.QAMS.Author
  @moduledoc """
  Schema for Author
  """

  schema "qams_authors" do
    field :role, :string
    belongs_to :user, OntagCore.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(%Author{} = author, attrs) do
    author
    |> cast(attrs, [:role])
    |> validate_required([:role])
    |> validate_inclusion(:role, ["questioner", "annotator", "admin"])
  end
end
