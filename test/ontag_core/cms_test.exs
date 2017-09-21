defmodule OntagCore.CMSTest do
  use OntagCore.DataCase
  alias OntagCore.CMS

  setup do
    user = create_test_user()
    author = create_test_cms_author(user)
    entry = create_test_entry(author)
    entry2 = create_test_entry(author, "external_html")
    entry3 = create_test_entry(author, "medium_post")
    qams_author = create_test_qams_author(user)
    tag = create_test_tag(qams_author)
    create_test_annotation(qams_author, entry, tag)

    map = %{
      user: user,
      author: author,
      entries: [entry, entry2, entry3]
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

  test "List of all entries", %{entries: [e1, e2, e3]} do
    result = CMS.list_entries()

    assert Enum.member?(result, e1)
    assert Enum.member?(result, e2)
    assert Enum.member?(result, e3)
  end

  test "Get an existing entry", %{entries: [entry, _, _]} do
    entry =
      entry
      |> Repo.preload(:author)
      |> Repo.preload(:external_html)
      |> Repo.preload(:medium_post)

    assert {:ok, entry} == CMS.get_entry(entry.id)
  end

  test "Delete an entry", %{author: author} do
    entry = create_test_entry(author)
    assert {:ok, _} = CMS.delete_entry(entry.id)
  end

  test "Delete an entry with content", %{author: author} do
    entry = create_test_entry(author, "external_html")
    assert {:ok, _} = CMS.delete_entry(entry.id)
  end

  test "Delete an entry with annotations", %{entries: [entry, _, _]} do
    assert {:error, _} = CMS.delete_entry(entry.id)
  end
end
