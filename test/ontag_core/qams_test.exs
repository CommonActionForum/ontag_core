defmodule OntagCore.QAMSTest do
  use OntagCore.DataCase
  alias OntagCore.QAMS

  setup do
    user = create_test_user()
    qams_author = create_test_qams_author(user)
    cms_author = create_test_cms_author(user)
    tag1 = create_test_tag(qams_author)
    tag2 = create_test_tag(qams_author)
    tag3 = create_test_tag(qams_author)
    question = create_test_question(qams_author)
    question2 = create_test_question(qams_author)
    entry = create_test_entry(cms_author)
    an1 = create_test_annotation(qams_author, entry, tag2)
    create_test_question_tag(qams_author, question, tag3)
    answer = create_test_answer(question2)
    create_test_answer_annotation(answer, an1)

    world = %{
      user: user,
      author: qams_author,
      tags: [tag1, tag2, tag3],
      question: question,
      entry: entry,
      annotation: an1,
      answer: answer
    }

    {:ok, world}
  end

  test "Ensure that an author exists", %{user: user} do
    author = QAMS.ensure_author_exists(user)
    author2 = QAMS.ensure_author_exists(user)
    assert author.user_id == user.id
    assert author == author2
  end

  test "Create a tag", %{author: author} do
    params = %{
      title: "Hello World"
    }

    assert {:ok, entry} = QAMS.create_tag(author, params)
    assert entry.title == "Hello World"
  end

  test "Get a list of tags", %{tags: [tag1, tag2, _]} do
    result = QAMS.list_tags()

    assert Enum.member?(result, tag1)
    assert Enum.member?(result, tag2)
  end

  test "Get a non-existent tag" do
    assert {:error, :not_found} == QAMS.get_tag(0)
  end

  test "Get a tag", %{tags: [tag, _, _]} do
    assert {:ok, tag} == QAMS.get_tag(tag.id)
  end

  test "Delete an unsed tag", %{tags: [tag, _, _]} do
    assert {:ok, tag} = QAMS.delete_tag(tag.id)
    assert {:error, :not_found} == QAMS.get_tag(tag.id)
  end

  test "Delete an used tag in annotation", %{tags: [_, tag, _]} do
    assert {:error, _} = QAMS.delete_tag(tag.id)
  end

  test "Delete an used tag in question", %{tags: [_, _, tag]} do
    assert {:error, _} = QAMS.delete_tag(tag.id)
  end

  test "Update a tag", %{tags: [tag, _, _]} do
    expected = Map.put(tag, :title, "Hello Mars")
    assert {:ok, result} = QAMS.update_tag(tag.id, %{title: "Hello Mars"})

    {t1, e1} = Map.pop(expected, :updated_at)
    {t2, e2} = Map.pop(result, :updated_at)

    assert e1 == e2
    assert NaiveDateTime.compare(t1, t2) != :gt
  end

  test "Create a question with valid tags", %{author: author, tags: [tag1, tag2, _]} do
    question_params = %{
      title: "Hello World",
      required_tags: [tag1.id],
      optional_tags: [tag2.id]
    }

    assert {:ok, _} = QAMS.create_question(author, question_params)
  end

  test "Create a question with non-valid tags", %{author: author} do
    question_params = %{
      title: "Hello World",
      required_tags: [],
      optional_tags: [0, -1]
    }

    {:error, _} = QAMS.create_question(author, question_params)
  end

  test "Get a list of all questions" do
    assert [_, _] = QAMS.list_questions
  end

  test "Get a question", %{question: question} do
    question = Repo.preload(question, :tags)
    assert {:ok, question} == QAMS.get_question(question.id)
  end

  test "Delete a question", %{question: question} do
    question = Repo.preload(question, :tags)
    assert {:ok, _} = QAMS.delete_question(question.id)
  end

  test "Create an annotation", %{author: author, entry: entry, tags: [tag1, _, _]}  do
    params = %{
      tag_id: tag1.id,
      entry_id: entry.id,
      target: %{}
    }

    assert {:ok, _} = QAMS.create_annotation(author, params)
  end

  test "Get a list of all annotations" do
    assert [_] = QAMS.list_annotations()
  end

  test "Get an annotation", %{annotation: annotation} do
    assert {:ok, _} = QAMS.get_annotation(annotation.id)
  end

  test "Get a non-existent annotation" do
    assert {:error, :not_found} == QAMS.get_annotation(0)
  end

  test "Delete an annotation", %{annotation: annotation} do
    assert {:ok, _} = QAMS.delete_annotation(annotation.id)
  end

  test "Delete an annotation used in an answer", %{annotation: annotation, question: question} do
    answer = create_test_answer(question)
    create_test_answer_annotation(answer, annotation)

    assert {:ok, _} = QAMS.delete_annotation(annotation.id)
  end

  test "Create an answer", %{author: author, question: question, annotation: annotation} do
    params = %{
      question_id: question.id,
      annotations: [annotation.id]
    }
    assert {:ok, _} = QAMS.create_answer(author, params)
  end

  test "Get an answer", %{answer: answer} do
    assert {:ok, _} = QAMS.get_answer(answer.id)
  end

  test "Get a non-existent answer" do
    assert {:error, :not_found} == QAMS.get_answer(0)
  end

  test "Delete an answer", %{answer: answer} do
    assert {:ok, _} = QAMS.delete_answer(answer.id)
  end

  test "Delete a non-existent answer" do
    assert {:error, :not_found} == QAMS.delete_answer(0)
  end
end
