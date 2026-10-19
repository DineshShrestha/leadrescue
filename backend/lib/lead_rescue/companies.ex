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

  def get_company(id) do
    Repo.get(Company, id)
  end

  def update_company(company, attrs) do
    company
    |> Company.changeset(attrs)
    |> Repo.update()
  end
end
