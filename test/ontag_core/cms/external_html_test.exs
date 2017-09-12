defmodule OntagCore.CMS.ExternalHTMLTest do
  use OntagCore.DataCase
  alias OntagCore.CMS.ExternalHTML
  @moduledoc """
  Tests for `OntagCore.CMS.ExternalHTML`
  """

  test "Valid data on changeset" do
    params = %{
      uri: "http://example.com"
    }

    changeset = ExternalHTML.changeset(%ExternalHTML{}, params)
    assert changeset.valid?
  end

  test "Invalid data on changeset: no uri" do
    params = %{}

    changeset = ExternalHTML.changeset(%ExternalHTML{}, params)
    assert %{uri: ["can't be blank"]} = errors_on(changeset)
  end
end
