defmodule LeadRescue.Companies do
  alias LeadRescue.Companies.Company

  alias LeadRescue.Repo

  def create_company(attrs) do
    %Company{}
    |> Company.changeset(attrs)
    |> Repo.insert()
  end

  def list_companies do
    Repo.all(Company)
  end
end
