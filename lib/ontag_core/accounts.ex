defmodule OntagCore.Accounts do
  alias OntagCore.Repo
  alias OntagCore.Accounts.{User,
                            PasswordCredential,
                            MediumCredential}
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

  @doc """
  Get data needed to log in a `user` via medium: a `state` (returned directly by
  this function) and a `code`.

  To get the `code`, follow the steps in
  [Medium API documentation](https://github.com/Medium/medium-api-docs#2-authentication)
  to redirect the user to a page in your domain with a short-term authorization
  code.

  From that redirect_uri, collect the `state` and `code` and call
  `login_with_medium/2`.
  """
  def get_medium_login_data(user) do
    # If the user has MediumCredential, refresh the `state` with a random
    # generated one.

    # Otherwise, create a MediumCredential with a random generated "state"
    # linked with `user`
    state = Base.encode16(:crypto.strong_rand_bytes(8))

    case Repo.get_by(MediumCredential, user_id: user.id) do
      nil -> %MediumCredential{user_id: user.id}
      credential -> credential
    end
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:state, state)
    |> Repo.insert_or_update!()

    state
  end

  @doc """
  Authenticate a user via medium giving a `state` and a `code`

  To get both `state` and `code`, use `get_medium_login_data/0` or
  `get_medium_login_data/1`
  """
  def login_with_medium(state, code) do
    state
    |> get_medium_credential_from_state()
    |> get_medium_long_lived_token(code)
    |> get_medium_user_data()
    |> update_medium_data()
    |> ensure_user_exists()
  end

  @doc """
  Retrieve a MediumCredential
  """
  defp get_medium_credential_from_state(state) do
    case Repo.get_by(MediumCredential, state: state) do
      nil -> {:error, :not_found}
      credential -> {:ok, credential}
    end
  end

  @doc """
  Request a Medium Long-lived token from its API
  """
  def get_medium_long_lived_token({:ok, credential}, code) do
    uri = "https://api.medium.com/v1/tokens"
    body = [
      code: code,
      client_id: Application.get_env(:ontag_core, OntagCore.Accounts)[:medium_client_id],
      client_secret: Application.get_env(:ontag_core, OntagCore.Accounts)[:medium_client_secret],
      grant_type: "authorization_code",
      redirect_uri: Application.get_env(:ontag_core, OntagCore.Accounts)[:medium_redirect_uri]
    ]

    headers = %{
      "Content-Type" => "application/x-www-form-urlencoded",
      "Accept" => "application/json"
    }

    with {:ok, %{"access_token" => access_token}} <-
      uri
      |> HTTPoison.post({:form, body}, headers)
      |> handle_json_response(201)
    do
      {:ok, credential, access_token}
    end
  end
  def get_medium_long_lived_token(any, _), do: any

  @doc """
  Get current user data from a Medium Token
  """
  def get_medium_user_data({:ok, credential, access_token}) do
    uri = "https://api.medium.com/v1/me"
    headers = %{
      "Content-Type" => "application/json",
      "Accept" => "application/json",
      "Authorization" => "Bearer #{access_token}"
    }
    with {:ok, %{"data" => data}} <-
      uri
      |> HTTPoison.get(headers)
      |> handle_json_response(200)
    do
      {:ok, credential, data}
    end
  end
  def get_medium_user_data(any), do: any

  defp handle_json_response({:ok, response}, status_code) do
    %{body: json_body,
      status_code: code} = response

    case code do
      ^status_code ->
        Poison.decode(json_body)
      _ ->
        {:error, json_body}
    end
  end
  defp handle_json_response(any, _), do: any

  @doc """
  Update a MediumCredential
  """
  def update_medium_data({:ok, new_credential, data}) do
    %{
      "id" => medium_id,
      "imageUrl" => image_url,
      "name" => name,
      "url" => url,
      "username" => username
    } = data

    attrs = %{
      medium_id: medium_id,
      username: username,
      name: name,
      url: url,
      image_url: image_url
    }

    case Repo.get_by(MediumCredential, medium_id: medium_id) do
      nil ->
        new_credential
        |> MediumCredential.changeset(attrs)
        |> Repo.update()

      old_credential ->
        old_credential
        |> MediumCredential.changeset(attrs)
        |> Repo.update()

    end
  end
  def update_medium_data(any), do: any

  @doc """
  Given a MediumCredential, creates a User if necessary
  """
  def ensure_user_exists({:ok, %MediumCredential{} = credential}) do
    %{user: user,
      username: username} = Repo.preload(credential, :user)

    params = %{
      username: username <> Base.encode16(:crypto.strong_rand_bytes(3))
    }

    case user do
      nil ->
        {:ok, user} =
          %User{}
          |> User.changeset(params)
          |> Repo.insert()

        credential
        |> Ecto.Changeset.change(user_id: user.id)
        |> Repo.update()

        {:ok, user}
      _ ->
        {:ok, user}
    end
  end
  def ensure_user_exists(any), do: any
end
