defmodule LeadRescue.Companies.Company do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "companies" do
    field :name, :string
    field :slug, :string
    field :organization_number, :string
    field :email, :string
    field :phone, :string
    field :website, :string
    field :address, :string
    field :postcode, :string
    field :city, :string
    field :timezone, :string, default: "Europe/Oslo"

    field :subscription_status, :string, default: "trial"
    field :subscription_plan, :string, default: "trial"
    field :trial_ends_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  def changeset(company, attrs) do
    company
    |> cast(attrs, [
      :name,
      :slug,
      :organization_number,
      :email,
      :phone,
      :website,
      :address,
      :postcode,
      :city,
      :timezone
    ])
    |> validate_required([:name, :slug])
    |> unique_constraint(:slug)
  end
end
