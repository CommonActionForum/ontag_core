defmodule OntagCore.QAMS do
  use Ecto.Schema
  import Ecto.Changeset
  alias OntagCore.Repo
  alias OntagCore.QAMS.{Tag,
                        Question,
                        Author,
                        Annotation,
                        QuestionTag,
                        Answer,
                        AnswerAnnotation}
  alias OntagCore.Accounts
  alias Ecto.Multi

  @moduledoc """
  Questions and Answers Manager System. Create questions, annotations and
  answers.
  """

  @doc """
  Creates a tag
  """
  def create_tag(%Author{} = author, params) do
    %Tag{}
    |> Tag.changeset(params)
    |> put_change(:author_id, author.id)
    |> Repo.insert()
  end

  @doc """
  Get a list of all tags
  """
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Get one tag given its ID
  """
  def get_tag(id) do
    case Repo.get(Tag, id) do
      nil ->
        {:error, :not_found}
      tag ->
        {:ok, tag}
    end
  end

  @doc """
  Deletes a tag
  """
  def delete_tag(id) do
    with {:ok, tag} <- get_tag(id) do
      changeset =
        tag
        |> change()
        |> foreign_key_constraint(
          :annotations,
          name: :annotations_tag_id_fkey,
          message: "This tag cannot be deleted because is part of some annotations"
        )
        |> foreign_key_constraint(
          :annotations,
          name: :questions_tags_tag_id_fkey,
          message: "This tag cannot be deleted because is part of some question"
        )

      Repo.delete(changeset)
    end
  end

  @doc """
  Updates a tag
  """
  def update_tag(id, params) do
    with {:ok, tag} <- get_tag(id) do
      tag
      |> Tag.changeset(params)
      |> Repo.update()
    end
  end

  @doc """
  Creates a question
  """
  def create_question(%Author{} = author, params) do
    Repo.transaction(fn ->
      ch = Question.changeset(%Question{}, params)

      required_tags = get_change(ch, :required_tags, [])
      optional_tags = get_change(ch, :optional_tags, [])

      result =
        ch
        |> put_change(:author_id, author.id)
        |> Repo.insert()
        |> add_tags(author, required_tags, optional_tags)

      case result do
        {:error, changeset} ->
          Repo.rollback(changeset)

        {:ok, question, tags} ->
          Map.put(question, :tags, tags)
      end
    end)
  end

  defp add_tags({:error, changeset}, _, _, _), do: {:error, changeset}
  defp add_tags({:ok, question}, author, required_tags, optional_tags) do
    rt =
      required_tags
      |> Enum.map(fn tag -> %{question_id: question.id, tag_id: tag, required: true} end)

    ot =
      optional_tags
      |> Enum.map(fn tag -> %{question_id: question.id, tag_id: tag, required: false} end)

    tags = Enum.concat(rt, ot)

    tags
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

  @doc """
  Gets a list of all questions
  """
  def list_questions do
    Repo.all(Question)
  end

  @doc """
  Get one question given its ID
  """
  def get_question(id) do
    case Repo.get(Question, id) do
      nil ->
        {:error, :not_found}
      question ->
        question = Repo.preload(question, :tags)
        {:ok, question}
    end
  end

  @doc """
  Deletes a question
  """
  def delete_question(id) do
    with {:ok, question} <- get_question(id) do
      Repo.delete(question)
    end
  end


  def create_annotation(%Author{} = author, params) do
    %Annotation{}
    |> Annotation.changeset(params)
    |> put_change(:author_id, author.id)
    |> Repo.insert()
  end

  def create_answer(%Author{} = author, %{question_id: question_id, annotations: annotations}) do
    Repo.transaction(fn ->
      result =
        %Answer{question_id: question_id}
        |> change()
        |> put_change(:author_id, author.id)
        |> cast(%{question_id: question_id}, [:question_id])
        |> Repo.insert()
        |> add_annotations(author, annotations)

      case result do
        {:error, changeset} ->
          Repo.rollback(changeset)

        {:ok, answer, annotations} ->
          Map.put(answer, :annotations, annotations)
      end
    end)
  end
  def create_answer(%Author{} = author, %{"question_id" => question_id, "annotations" => annotations}) do
    create_answer(author, %{question_id: question_id, annotations: annotations})
  end
  def create_answer(_, _), do: {:error, :bad_request}

  defp add_annotations({:error, changeset}, _, _), do: {:error, changeset}
  defp add_annotations({:ok, answer}, author, annotations) do
    annotations
    |> Enum.map(fn ann -> %{annotation_id: ann,
                            answer_id: answer.id} end)
    |> Enum.map(fn params -> AnswerAnnotation.changeset(%AnswerAnnotation{}, params) end)
    |> Enum.map(fn ch -> put_change(ch, :author_id, author.id) end)
    |> Enum.reduce({:ok, answer, []}, &add_annotation/2)
  end

  defp add_annotation(_ch, {:error, changeset}), do: {:error, changeset}
  defp add_annotation(ch = %{valid?: valid}, {:ok, _, _}) when not valid do
    {:error, ch}
  end
  defp add_annotation(ch, {:ok, answer, annotations}) do
    case Repo.insert(ch) do
      {:ok, annotation} ->
        {:ok, answer, [annotation | annotations]}

      {:error, changeset} ->
        {:error, changeset}
    end
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
