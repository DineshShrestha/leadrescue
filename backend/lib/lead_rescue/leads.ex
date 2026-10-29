defmodule LeadRescue.Leads do
  alias LeadRescue.Leads.Lead
  alias LeadRescue.Repo
  import Ecto.Query

  def create_lead(company, attrs) do
    %Lead{company_id: company.id}
    |> Lead.changeset(attrs)
    |> Repo.insert()
  end

  def list_leads(company) do
    Lead
    |> where([lead], lead.company_id == ^company.id)
    |> Repo.all()
  end
end
