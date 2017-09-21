defmodule OntagCore.Repo.Migrations.CreateCms do
  use Ecto.Migration

  def change do
    create table(:cms_authors) do
      add :role, :string
      add :user_id, references(:users, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create table(:entries) do
      add :title, :string
      add :entry_type, :string
      add :author_id, references(:cms_authors),
        null: false

      timestamps()
    end

    create table(:medium_posts) do
      add :title, :string
      add :uri, :string
      add :publishing_date, :utc_datetime
      add :license, :string
      add :tags, {:array, :string}
      add :entry_id, references(:entries, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create table(:external_htmls) do
      add :uri, :string
      add :entry_id, references(:entries, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create unique_index(:cms_authors, [:user_id])
    create index(:entries, [:author_id])
    create index(:medium_posts, [:entry_id])
    create index(:external_htmls, [:entry_id])
  end
end
