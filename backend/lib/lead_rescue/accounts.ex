defmodule LeadRescue.Accounts do
  alias LeadRescue.Repo
  alias LeadRescue.Accounts.User

  def create_user(company, attrs) do
    %User{company_id: company.id}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_user_by_email_and_password(email, password) do
    user = Repo.get_by(User, email: email)

    cond do
      user && Bcrypt.verify_pass(password, user.hashed_password) ->
        user

      user ->
        nil

      true ->
        Bcrypt.no_user_verify()
        nil
    end
  end

  def get_user(id) do
    case Ecto.UUID.cast(id) do
      {:ok, valid_id} -> Repo.get(User, valid_id)
      :error -> nil
    end
  end
end
