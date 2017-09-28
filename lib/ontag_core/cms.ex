defmodule OntagCore.CMS do
  use Ecto.Schema
  import Ecto.Changeset
  alias OntagCore.Repo
  alias OntagCore.CMS.{Entry,
                       Author,
                       ExternalHTML,
                       MediumPost}
  alias OntagCore.Accounts

  @moduledoc """
  Content Manager System. Create entries (things that can potentially answer
  a question) and manage them.

  *Entry* is the generic object that contains information of the content
  """

  @doc """
  Creates an entry
  """
  def create_entry(%Author{} = author, params) do
    %Entry{}
    |> Entry.changeset(params)
    |> assoc_entry_content()
    |> put_change(:author_id, author.id)
    |> Repo.insert()
  end

  defp assoc_entry_content(changeset) do
    case fetch_change(changeset, :entry_type) do
      {:ok, "external_html"} ->
        Ecto.Changeset.cast_assoc(
          changeset,
          :external_html,
          with: &ExternalHTML.changeset/2)

      {:ok, "medium_post"} ->
        Ecto.Changeset.cast_assoc(
          changeset,
          :medium_post,
          with: &MediumPost.changeset/2)

      _ ->
        changeset
    end
  end

  @doc """
  Get a list of all entries
  """
  def list_entries do
    Repo.all(Entry)
  end

  @doc """
  Get an entry from its ID
  """
  def get_entry(id) do
    case Repo.get(Entry, id) do
      nil ->
        {:error, :not_found}
      entry ->
        entry =
          entry
          |> Repo.preload(:medium_post)
          |> Repo.preload(:author)
          |> Repo.preload(:external_html)

        {:ok, entry}
    end
  end

  @doc """
  Deletes an entry
  """
  def delete_entry(id) do
    with {:ok, entry} <- get_entry(id) do
      entry
      |> change()
      |> foreign_key_constraint(
        :annotations,
        name: :annotations_entry_id_fkey,
        message: "This entry has annotations and cannot be deleted")
      |> Repo.delete()
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
