defmodule LeadRescue.Accounts do
  alias LeadRescue.Repo
  alias LeadRescue.Accounts.User

  def create_user(company, attrs) do
    %User{company_id: company.id}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)

    cond do
      user == nil ->
        Bcrypt.no_user_verify()
        nil

      Bcrypt.verify_pass(password, user.hashed_password) and user.active ->
        user

      true ->
        nil
    end
  end

  def get_user_by_email_and_password(_email, _password) do
    Bcrypt.no_user_verify()
    nil
  end

  def get_user(id) do
    case Ecto.UUID.cast(id) do
      {:ok, valid_id} -> Repo.get(User, valid_id)
      :error -> nil
    end
  end
end
