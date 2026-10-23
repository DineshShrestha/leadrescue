defmodule LeadRescueWeb.AuthTokenTest do
  use ExUnit.Case, async: true
  alias LeadRescue.Accounts.User
  alias LeadRescueWeb.AuthToken

  test "signs and verifies a user token" do
    user = %User{id: Ecto.UUID.generate()}

    token = AuthToken.sign(user)

    assert is_binary(token)
    assert {:ok, user_id} = AuthToken.verify(token)
    assert user_id == user.id
  end

  test "rejects a modified token" do
    user = %User{id: Ecto.UUID.generate()}

    token = AuthToken.sign(user)

    modified_token = token <> "modified"
    assert {:error, _reason} = AuthToken.verify(modified_token)
  end
end
