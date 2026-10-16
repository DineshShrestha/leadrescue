defmodule LeadRescue.Accounts do
  alias LeadRescue.Repo
  alias LeadRescue.Accounts.User

  def get_user_by_email_and_password(email, password) do
    user = Repo.get_by(User, email: email)

    cond do
      user && Bcrypt.verify_pass(password, user.hashed_password) -> user
      user -> nil
      true -> Bcrypt.no_user_verify() && nil
    end
  end
end
