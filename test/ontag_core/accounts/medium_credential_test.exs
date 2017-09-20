defmodule OntagCore.Accounts.MediumCredentialTest do
  use OntagCore.DataCase
  alias OntagCore.Accounts.MediumCredential
  @moduledoc """
  Tests for `OntagCore.Accounts.MediumCredential`
  """

  test "Valid data on changeset" do
    params = %{
      medium_id: "id",
      username: "username",
      url: "url",
      name: "name"
    }

    changeset = MediumCredential.changeset(%MediumCredential{}, params)
    assert changeset.valid?
  end
end
