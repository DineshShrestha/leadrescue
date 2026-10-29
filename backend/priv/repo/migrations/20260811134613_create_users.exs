defmodule LeadRescue.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :company_id, references(:companies, type: :binary_id, on_delete: :delete_all)
      add :email, :string, null: false
      add :hashed_password, :string, null: false
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :role, :string, null: false, default: "company_user"
      add :active, :boolean, null: false, default: true
      add :last_login_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    create index(:users, [:company_id])
  end
end
