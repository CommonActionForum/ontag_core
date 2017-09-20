defmodule OntagCore.QAMS do
  use Ecto.Schema
  import Ecto.Changeset
  alias OntagCore.Repo
  alias OntagCore.QAMS.{Tag,
                        Question,
                        Author,
                        Annotation,
                        QuestionTag}
  alias OntagCore.Accounts
  alias Ecto.Multi

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
  def create_question(%Author{} = author, question_params, tags_params) do
    # Changesets
    Repo.transaction(fn ->
      result =
        %Question{}
        |> Question.changeset(question_params)
        |> put_change(:author_id, author.id)
        |> Repo.insert()
        |> add_tags(author, tags_params)

      case result do
        {:error, changeset} ->
          Repo.rollback(changeset)

        {:ok, question, tags} ->
          Map.put(question, :tags, tags)
      end
    end)
  end

  defp add_tags({:error, changeset}, _, _), do: {:error, changeset}
  defp add_tags({:ok, question}, author, tags) do
    tags
    |> Enum.map(fn tag -> %{question_id: question.id,
                            tag_id: tag.tag_id,
                            required: tag.required} end)
    |> Enum.map(fn params -> QuestionTag.changeset(%QuestionTag{}, params) end)
    |> Enum.map(fn ch -> put_change(ch, :author_id, author.id) end)
    |> Enum.reduce({:ok, question, []}, &add_tag/2)
  end

  defp add_tag(_changeset, {:error, changeset}), do: {:error, changeset}
  defp add_tag(changeset = %{valid?: valid}, {:ok, _, _}) when not valid do
    {:error, changeset}
  end
  defp add_tag(changeset, {:ok, question, tags}) do
    case Repo.insert(changeset) do
      {:ok, tag} ->
        {:ok, question, [tag | tags]}

      {:error, changeset} ->
        {:error, changeset}
    end
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
