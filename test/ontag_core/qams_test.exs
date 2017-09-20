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

  #  test "Create an annotation" do
  #    user_params = %{
  #      username: "john_example",
  #      name: "John example"
  #    }
  #
  #    {:ok, user} = OntagCore.Accounts.create_user(user_params)
  #    author = QAMS.ensure_author_exists(user)
  #
  #    params = %{
  #      target: %{
  #        type: "type of the annotation"
  #      }
  #    }
  #
  #    assert {:ok, entry} = QAMS.create_annotation(author, params)
  #    assert entry.title == "Hello World"
  #  end
end
