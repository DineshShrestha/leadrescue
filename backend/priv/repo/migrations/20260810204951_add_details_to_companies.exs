defmodule LeadRescue.Repo.Migrations.AddDetailsToCompanies do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add :organization_number, :string
      add :email, :string
      add :phone, :string
      add :website, :string
      add :address, :string
      add :postcode, :string
      add :city, :string
      add :timezone, :string, null: false, default: "Europe/Oslo"

      add :subscription_status, :string, null: false, default: "trial"
      add :subscription_plan, :string, null: false, default: "trial"
      add :trial_ends_at, :utc_datetime
    end
  end
end
