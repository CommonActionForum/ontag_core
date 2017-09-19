defmodule OntagCore.QAMS do
  use Ecto.Schema
  import Ecto.Changeset
  alias OntagCore.Repo
  alias OntagCore.QAMS.{Tag,
                        Question,
                        Author,
                        Annotation}
  alias OntagCore.Accounts

  @moduledoc """
  Questions and Answers Manager System. Create questions, annotations and
  answers.
  """

  def create_tag(%Author{} = author, params) do
    %Tag{}
    |> Tag.changeset(params)
    |> put_change(:author_id, author.id)
    |> Repo.insert()
  end

  @doc """
  Creates a question
  """
  def create_question(%Author{} = author, params) do
    %Question{}
    |> Question.changeset(params)
    |> put_change(:author_id, author.id)
    |> Repo.insert()
  end

  def create_annotation(%Author{} = author, params) do
    %Annotation{}
    |> Annotation.changeset(params)
    |> put_change(:author_id, author.id)
    |> Repo.insert()
  end

  def ensure_author_exists(%Accounts.User{} = user) do
    %Author{user_id: user.id}
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.unique_constraint(:user_id)
    |> Repo.insert()
    |> handle_existing_author()
  end

  defp handle_existing_author({:ok, author}), do: author
  defp handle_existing_author({:error, changeset}) do
    Repo.get_by!(Author, user_id: changeset.data.user_id)
  end
end
