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

  @doc """
  Get a `User` given its PasswordCredential data
  """
  def authenticate_with_password_credential(email, password) do
    email
    |> get_password_credential_from_email()
    |> check_password(password)
    |> get_user_from_password_credential()
  end

  @doc """
  Get a `PasswordCredential` given its email
  """
  def get_password_credential_from_email(email) do
    case Repo.get_by(PasswordCredential, email: email) do
      %PasswordCredential{} = pc ->
        {:ok, pc}
      nil ->
        {:error, :unauthorized}
    end
  end

  @doc """
  Check if, a given `PasswordCredential` has a certain password.

  Returns `{:ok, pc}` on success, and `{:error, :unauthorized}` on failure.
  """
  def check_password({:ok, %PasswordCredential{} = pc}, password) do
    case Comeonin.Bcrypt.check_pass(pc, password) do
      {:error, _} ->
        {:error, :unauthorized}
      {:ok, pc} ->
        {:ok, pc}
    end
  end
  def check_password(any, _), do: any

  @doc """
  Get the user associated with a password credential.
  """
  def get_user_from_password_credential({:ok, %PasswordCredential{} = pc}) do
    pc = Repo.preload(pc, :user)
    {:ok, pc.user}
  end
  def get_user_from_password_credential(any), do: any
end
