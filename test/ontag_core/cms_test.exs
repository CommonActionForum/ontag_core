defmodule OntagCore.CMSTest do
  use OntagCore.DataCase
  alias OntagCore.CMS
  alias OntagCore.CMS.Entry

  test "Ensure that an author exists" do
    params = %{
      username: "john_example",
      name: "John example"
    }

    {:ok, user} = OntagCore.Accounts.create_user(params)
    author = CMS.ensure_author_exists(user)
    author2 = CMS.ensure_author_exists(user)
    assert author.user_id == user.id
    assert author == author2
  end

  test "Create an entry without content successfully" do
    user_params = %{
      username: "john_example",
      name: "John example"
    }

    {:ok, user} = OntagCore.Accounts.create_user(user_params)
    author = CMS.ensure_author_exists(user)

    params = %{
      title: "Hello World"
    }

    assert {:ok, entry} = CMS.create_entry(author, params)
    assert entry.title == "Hello World"
  end

  test "Create an medium post entry" do
    user_params = %{
      username: "john_example",
      name: "John example"
    }

    {:ok, user} = OntagCore.Accounts.create_user(user_params)
    author = CMS.ensure_author_exists(user)

    params = %{
      title: "Hello World",
      entry_type: "external_html",
      external_html: %{
        uri: "http://www.example.com"
      }
    }

    assert {:ok, entry} = CMS.create_entry(author, params)
  end
end
