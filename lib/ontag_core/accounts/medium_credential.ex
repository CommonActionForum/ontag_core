defmodule OntagCore.Accounts.MediumCredential do
  use Ecto.Schema
  import Ecto.Changeset
  alias OntagCore.Accounts.{MediumCredential,
                            User}
  @moduledoc """
  Schema for Medium Credential
  """

  schema "medium_credentials" do
    field :medium_id, :string
    field :username, :string
    field :name, :string
    field :url, :string
    field :image_url, :string
    field :state, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%MediumCredential{} = credential, attrs) do
    credential
    |> cast(attrs, [:medium_id, :username, :name, :url, :image_url])
    |> validate_required([:medium_id, :username, :url, :name])
  end
end
