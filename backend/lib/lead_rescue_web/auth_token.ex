defmodule LeadRescueWeb.AuthToken do
  alias LeadRescue.Accounts.User
  alias LeadRescueWeb.Endpoint

  @salt "user authentication"
  @max_age 60 * 60 * 24 * 7

  def sign(%User{id: user_id}) do
    Phoenix.Token.sign(Endpoint, @salt, user_id)
  end

  def verify(token) when is_binary(token) do
    Phoenix.Token.verify(
      Endpoint,
      @salt,
      token,
      max_age: @max_age
    )
  end
end
