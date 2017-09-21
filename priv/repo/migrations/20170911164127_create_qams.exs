defmodule OntagCore.Repo.Migrations.CreateQams do
  use Ecto.Migration

  def change do
    create table(:qams_authors) do
      add :role, :string
      add :user_id, references(:users, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create table(:tags) do
      add :title, :string
      add :author_id, references(:qams_authors),
        null: false

      timestamps()
    end

    create table(:questions) do
      add :title, :string
      add :author_id, references(:qams_authors),
        null: false

      timestamps()
    end

    create table(:questions_tags) do
      add :question_id, references(:questions, on_delete: :delete_all),
        null: false
      add :tag_id, references(:tags),
        null: false
      add :required, :boolean
      add :author_id, references(:qams_authors),
        null: false

      timestamps()
    end

    create table(:annotations) do
      add :entry_id, references(:entries),
        null: false
      add :type, :string
      add :target, :map
      add :tag_id, references(:tags),
        null: false
      add :author_id, references(:qams_authors),
        null: false

      timestamps()
    end

    create table(:answers) do
      add :question_id, references(:questions),
        null: false

      timestamps()
    end

    create table(:answers_annotations) do
      add :answer_id, references(:answers),
        null: false
      add :annotation_id, references(:annotations),
        null: false

      timestamps()
    end

    create unique_index(:qams_authors, [:user_id])
    create index(:questions, [:author_id])
    create index(:questions_tags, [:author_id])
    create index(:annotations, [:entry_id, :tag_id, :author_id])

  end
end
