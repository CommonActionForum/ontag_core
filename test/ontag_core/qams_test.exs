defmodule OntagCore.QAMSTest do
  use OntagCore.DataCase
  alias OntagCore.QAMS

  test "Ensure that an author exists" do
    params = %{
      username: "john_example",
      name: "John example"
    }

    {:ok, user} = OntagCore.Accounts.create_user(params)
    author = QAMS.ensure_author_exists(user)
    author2 = QAMS.ensure_author_exists(user)
    assert author.user_id == user.id
    assert author == author2
  end

  test "Create a tag" do
    user_params = %{
      username: "john_example",
      name: "John example"
    }

    {:ok, user} = OntagCore.Accounts.create_user(user_params)
    author = QAMS.ensure_author_exists(user)

    params = %{
      title: "Hello World"
    }

    assert {:ok, entry} = QAMS.create_tag(author, params)
    assert entry.title == "Hello World"
  end

  test "Create a question with valid tags" do
    user_params = %{
      username: "john_example",
      name: "John example"
    }

    {:ok, user} = OntagCore.Accounts.create_user(user_params)
    author = QAMS.ensure_author_exists(user)
    {:ok, tag1} = QAMS.create_tag(author, %{title: "Tag 1"})
    {:ok, tag2} = QAMS.create_tag(author, %{title: "Tag 2"})

    question_params = %{
      title: "Hello World"
    }

    tags_params = [
      %{tag_id: tag1.id, required: true},
      %{tag_id: tag2.id, required: false}
    ]

    assert {:ok, question} = QAMS.create_question(author, question_params, tags_params)
    assert question.title == "Hello World"
  end

  test "Create a question with non-valid tags" do
    user_params = %{
      username: "john_example",
      name: "John example"
    }

    {:ok, user} = OntagCore.Accounts.create_user(user_params)
    author = QAMS.ensure_author_exists(user)

    question_params = %{
      title: "Hello World"
    }

    tags_params = [
      %{tag_id: 1, required: true},
      %{tag_id: 0, required: false}
    ]

    {:error, _} = QAMS.create_question(author, question_params, tags_params)
  end

  test "Create an annotation" do
    # Steps
    # User -> cms_author -> entry
    #      -> qams_author -> tag -> question
    # -> annotation -> answer
    user_params = %{
      username: "john_example",
      name: "John example"
    }
    {:ok, user} = OntagCore.Accounts.create_user(user_params)

    cms_author = OntagCore.CMS.ensure_author_exists(user)
    qams_author = QAMS.ensure_author_exists(user)

    {:ok, entry} = OntagCore.CMS.create_entry(cms_author, %{title: "Example entry"})
    {:ok, tag1} = QAMS.create_tag(qams_author, %{title: "Tag 1"})
    {:ok, tag2} = QAMS.create_tag(qams_author, %{title: "Tag 2"})
    tag_params = [
      %{tag_id: tag1.id, required: true},
      %{tag_id: tag2.id, required: false}
    ]
    {:ok, _} = QAMS.create_question(qams_author, %{title: "Example question"}, tag_params)
    assert {:ok, _} = QAMS.create_annotation(qams_author, entry, tag1, %{target: %{}})
  end

  test "Create an answer" do
    user_params = %{
      username: "john_example",
      name: "John example"
    }
    {:ok, user} = OntagCore.Accounts.create_user(user_params)

    cms_author = OntagCore.CMS.ensure_author_exists(user)
    qams_author = QAMS.ensure_author_exists(user)

    {:ok, entry} = OntagCore.CMS.create_entry(cms_author, %{title: "Example entry"})
    {:ok, tag1} = QAMS.create_tag(qams_author, %{title: "Tag 1"})
    {:ok, tag2} = QAMS.create_tag(qams_author, %{title: "Tag 2"})
    tag_params = [
      %{tag_id: tag1.id, required: true},
      %{tag_id: tag2.id, required: false}
    ]
    {:ok, question} = QAMS.create_question(qams_author, %{title: "Example question"}, tag_params)
    assert {:ok, a1} = QAMS.create_annotation(qams_author, entry, tag1, %{target: %{}})
    assert {:ok, a2} = QAMS.create_annotation(qams_author, entry, tag2, %{target: %{}})
    assert {:ok, _} = QAMS.create_answer(qams_author, question, [a1, a2])
  end
end