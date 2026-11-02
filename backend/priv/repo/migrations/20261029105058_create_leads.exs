defmodule LeadRescue.Repo.Migrations.CreateLeads do
  use Ecto.Migration

  def change do
    create table(:leads, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :company_id, references(:companies, type: :binary_id, on_delete: :delete_all),
        null: false

      add :name, :string, null: false
      add :email, :string, null: false
      add :phone, :string
      add :message, :text, null: false
      add :status, :string, null: false, default: "new"
      add :source, :string, null: false, default: "contact_form"

      timestamps(type: :utc_datetime)
    end

    create index(:leads, [:company_id, :status])
  end
end
