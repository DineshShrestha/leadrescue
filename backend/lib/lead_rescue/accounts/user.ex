defmodule LeadRescue.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @roles ~w{super_admin company_admin company_user}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :first_name, :string
    field :last_name, :string
    field :role, :string, default: "company_user"
    field :active, :boolean, default: true
    field :last_login_at, :utc_datetime

    belongs_to :company, LeadRescue.Companies.Company

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :first_name, :last_name, :role, :company_id])
    |> validate_required([:email, :password, :first_name, :last_name])
    |> validate_length(:password, min: 8)
    |> validate_inclusion(:role, @roles)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> unique_constraint(:email)
    |> hash_password()
  end

  defp hash_password(changeset) do
    case get_change(changeset, :password) do
      nil ->
        changeset

      password ->
        changeset
        |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
        |> delete_change(:password)
    end
  end
end
