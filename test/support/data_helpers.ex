defmodule OntagCore.DataHelpers do
  alias OntagCore.{Repo,
                   Accounts,
                   CMS,
                   QAMS}

  defp rand do
    Base.encode16(:crypto.strong_rand_bytes(8))
  end

  @doc """
  Creates a valid `Accounts.User`
  """
  def create_test_user do
    Repo.insert!(
      %Accounts.User{
        username: "john__#{rand()}",
        name: "John example"
      }
    )
  end

  @doc """
  Creates a valid `CMS.Author`
  """
  def create_test_cms_author(user) do
    Repo.insert!(
      %CMS.Author{
        user_id: user.id
      }
    )
  end

  @doc """
  Creates a valid `CMS.Entry` without content
  """
  def create_test_entry(author) do
    Repo.insert!(
      %CMS.Entry{
        author_id: author.id,
        title: "Example entry #{rand()}"
      }
    )
  end

  @doc """
  Creates a valid `CMS.Entry`
  """
  def create_test_entry(author, entry_type) do
    entry = Repo.insert!(
      %CMS.Entry{
        author_id: author.id,
        title: "Example entry #{rand()}",
        entry_type: entry_type
      }
    )

    case entry_type do
      "medium_post" ->
        create_test_medium_post(entry.id)

      "external_html" ->
        create_test_external_html(entry.id)
    end

    entry
  end

  @doc """
  Creates a valid `CMS.MediumPost`
  """
  def create_test_medium_post(entry_id) do
    Repo.insert!(
      %CMS.MediumPost{
        entry_id: entry_id,
        uri: "http://medium.com/#{rand()}",
        title: "Example medium post #{rand()}",
        license: "Copyright",
        tags: ["tag 1", "tag 2"]
      }
    )
  end

  @doc """
  Creates a valid `CMS.ExternalHTML`
  """
  def create_test_external_html(entry_id) do
    Repo.insert!(
      %CMS.ExternalHTML{
        entry_id: entry_id,
        uri: "http://external-site.com/#{rand()}"
      }
    )
  end

  @doc """
  Creates a valid `QAMS.Author`
  """
  def create_test_qams_author(user) do
    Repo.insert!(
      %QAMS.Author{
        user_id: user.id
      }
    )
  end

  @doc """
  Creates a valid `QAMS.Tag`
  """
  def create_test_tag(author) do
    Repo.insert!(
      %QAMS.Tag{
        title: "Tag #{rand()}",
        author_id: author.id
      }
    )
  end

  @doc """
  Creates a valid `QAMS.Question`
  """
  def create_test_question(author) do
    Repo.insert!(
      %QAMS.Question{
        title: "Question #{rand()}",
        author_id: author.id
      }
    )
  end

  @doc """
  Creates a valid `QAMS.QuestionTag`
  """
  def create_test_question_tag(author, question, tag) do
    Repo.insert!(
      %QAMS.QuestionTag{
        author_id: author.id,
        question_id: question.id,
        tag_id: tag.id,
        required: false
      }
    )
  end

  @doc """
  Creates a valid `QAMS.Annotation`
  """
  def create_test_annotation(author, entry, tag) do
    Repo.insert!(
      %QAMS.Annotation{
        author_id: author.id,
        tag_id: tag.id,
        entry_id: entry.id,
        target: %{
          type: "TextQuoteSelector"
        }
      }
    )
  end
end
