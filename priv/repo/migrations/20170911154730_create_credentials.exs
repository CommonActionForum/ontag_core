defmodule OntagCore.Repo.Migrations.CreateCredentials do
  use Ecto.Migration

  def change do
    create table(:password_credentials) do
      add :email, :string
      add :encrypted_password, :string
      add :user_id, references(:users, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create table(:medium_credentials) do
      add :medium_id, :string
      add :username, :string
      add :name, :string
      add :url, :string
      add :image_url, :string
      add :state, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:password_credentials, [:email])
    create unique_index(:medium_credentials, [:medium_id])
    create index(:password_credentials, [:user_id])
    create index(:medium_credentials, [:user_id])
  end
end
