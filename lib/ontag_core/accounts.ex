defmodule OntagCore.Accounts do
  alias OntagCore.Repo
  alias OntagCore.Accounts.{User,
                            PasswordCredential}
  @moduledoc """
  Accounts manager. Create accounts and authenticate users.

  Ontag defines different two kinds of objects: *Users* and *Credentials*

  *Users*, modeled in `OntagCore.Accounts.User` represents a person, its
  personal data. By now, it only has two fields: username and name.

  *Credentials* are objects that contain ways to authenticate a user. A user
  could have several Credentials at the same time. Currently, Ontag allows two
  possible credentials:

  - `OntagCore.Accounts.PasswordCredential`. A password-based credential
  - `OntagCore.Accounts.MediumCredential`. A credential based on a Medium
    account
  """

  @doc """
  Creates a user and a password credential
  """
  def create_user(params) do
    %User{}
    |> User.changeset(params)
    |> Ecto.Changeset.cast_assoc(
      :password_credential, with: &PasswordCredential.changeset/2)
    |> Repo.insert()
  end
end
