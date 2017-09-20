defmodule OntagCore.CMSTest do
  use OntagCore.DataCase
  alias OntagCore.CMS

  setup do
    user = create_test_user()
    author = create_test_cms_author()

    map = %{
      user: user,
      author: author
    }

    {:ok, map}
  end

  test "Ensure that an author exists", %{user: user} do
    author = CMS.ensure_author_exists(user)
    author2 = CMS.ensure_author_exists(user)
    assert author.user_id == user.id
    assert author == author2
  end

  test "Create an entry without content successfully", %{author: author} do
    params = %{
      title: "Hello World"
    }

    assert {:ok, entry} = CMS.create_entry(author, params)
    assert entry.title == "Hello World"
  end

  test "Create an external html entry", %{author: author} do
    params = %{
      title: "Hello World",
      entry_type: "external_html",
      external_html: %{
        uri: "http://example.com"
      }
    }

    assert {:ok, _} = CMS.create_entry(author, params)
  end

  test "Create an medium post entry", %{author: author} do
    params = %{
      title: "Hello World",
      entry_type: "medium_post",
      medium_post: %{
        title: "Hello World",
        uri: "http://www.example.com",
        license: "copyright",
        tags: ["Example"],
        copyright_cesion: true
      }
    }

    assert {:ok, _} = CMS.create_entry(author, params)
  end
end
