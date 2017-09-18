defmodule OntagCore.GuardianTest do
  use OntagCore.DataCase
  alias OntagCore.Guardian

  test "From resource to serialized string" do
    assert {:ok, "User 123"} = Guardian.subject_for_token(%{id: 123}, "")
  end

  test "Fron serialized string to resource" do
    params = %{
      username: "john_example",
      name: "John example"
    }

    {:ok, user} = OntagCore.Accounts.create_user(params)

    assert {:ok, user} == Guardian.resource_from_claims(%{"sub" => "User #{user.id}"})
  end
end
