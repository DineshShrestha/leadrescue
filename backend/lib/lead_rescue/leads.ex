defmodule LeadRescue.Leads do
  alias LeadRescue.Leads.Lead
  alias LeadRescue.Repo

  def create_lead(company, attrs) do
    %Lead{company_id: company.id}
    |> Lead.changeset(attrs)
    |> Repo.insert()
  end
end
