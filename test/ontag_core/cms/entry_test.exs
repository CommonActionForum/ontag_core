defmodule OntagCore.CMS.EntryTest do
  use OntagCore.DataCase
  alias OntagCore.CMS.Entry
  @moduledoc """
  Tests for `OntagCore.CMS.Entry`
  """

  test "Valid data on changeset" do
    params = %{
      title: "Example",
      entry_type: "external_html"
    }

    changeset = Entry.changeset(%Entry{}, params)
    assert changeset.valid?
  end

  test "Invalid data on changeset: no title" do
    params = %{
      entry_type: "none"
    }

    changeset = Entry.changeset(%Entry{}, params)
    assert %{title: ["can't be blank"]} = errors_on(changeset)
  end

  test "Invalid data on changeset: invalid entry_type" do
    params = %{
      title: "Example",
      entry_type: "none"
    }

    changeset = Entry.changeset(%Entry{}, params)
    assert %{entry_type: ["is invalid"]} = errors_on(changeset)
  end
end
