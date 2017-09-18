defmodule OntagCore.Guardian do
  use Guardian, otp_app: :ontag_core

  def subject_for_token(resource, _claims) do
    {:ok, "User #{to_string(resource.id)}"}
  end

  def resource_from_claims(claims) do
    case claims["sub"] do
      "User " <> id ->
        {:ok, OntagCore.Repo.get(OntagCore.Accounts.User, id)}
      _ ->
        {:error, :unauthenticated}
    end
  end
end
