defmodule OntagCore.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias OntagCore.Accounts.{User,
                            PasswordCredential}

  @moduledoc """
  Schema for User
  """

  schema "users" do
    field :username, :string
    field :name, :string
    has_one :password_credential, PasswordCredential

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :username])
    |> validate_required([:username])
    |> update_change(:username, &String.downcase/1)
    |> validate_length(:username, min: 2, max: 20)
    |> validate_format(:username, ~r/^[a-z0-9_]+$/)
    |> unique_constraint(:username)
  end
end
