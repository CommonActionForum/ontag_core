defmodule OntagCore.DataHelpers do
  alias OntagCore.Repo

  @doc """
  Creates a valid `Accounts.User`
  """
  def create_test_user do
    %OntagCore.Accounts.User{
      username: "john_example",
      name: "John example"
    }
  |> Repo.insert!()
  end
end
