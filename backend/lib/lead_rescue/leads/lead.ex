defmodule LeadRescue.Leads.Lead do
  use Ecto.Schema

  import Ecto.Changeset

  @statuses ~w(new contacted qualified won lost)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "leads" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :message, :string
    field :status, :string, default: "new"
    field :source, :string, default: "contact_form"

    belongs_to :company, LeadRescue.Companies.Company

    timestamps(type: :utc_datetime)
  end

  def changeset(lead, attrs) do
    lead
    |> cast(attrs, [:name, :email, :phone, :message])
    |> validate_required([:name, :email, :message])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> validate_length(:name, max: 200)
    |> validate_length(:message, max: 5_000)
    |> foreign_key_constraint(:company_id)
  end

  def status_changeset(lead, attrs) do
    lead
    |> cast(attrs, [:status])
    |> validate_required([:status])
    |> validate_inclusion(:status, @statuses)
  end
end
