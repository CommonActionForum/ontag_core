defmodule OntagCore.DataHelpers do
  alias OntagCore.{Repo,
                   Accounts,
                   CMS}

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
  def create_test_cms_author do
    user = create_test_user()

    Repo.insert!(
      %CMS.Author{
        user_id: user.id
      }
    )
  end

  @doc """
  Creates a valid `CMS.Entry` without content
  """
  def create_test_entry() do
    author = create_test_cms_author()

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
  def create_test_entry(entry_type) do
    author = create_test_cms_author()
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
end
