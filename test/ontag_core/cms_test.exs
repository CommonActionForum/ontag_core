defmodule OntagCore.CMSTest do
  use OntagCore.DataCase
  alias OntagCore.CMS

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

  test "Create an external html entry" do
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
        uri: "http://example.com"
      }
    }

    assert {:ok, _} = CMS.create_entry(author, params)
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
      entry_type: "medium_post",
      medium_post: %{
        title: "Hello World",
        uri: "http://www.example.com",
        publishing_date: %DateTime{year: 2000, month: 2, day: 29, zone_abbr: "CET",
                                   hour: 23, minute: 0, second: 7, microsecond: {0, 0},
                                   utc_offset: 3600, std_offset: 0, time_zone: "Europe/Warsaw"},
        license: "copyright",
        tags: ["Example"],
        copyright_cesion: true
      }
    }

    assert {:ok, _} = CMS.create_entry(author, params)
  end
end
