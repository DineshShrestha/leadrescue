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
    case Ecto.UUID.cast(id) do
      {:ok, valid_id} ->
        Repo.get(Company, valid_id)

      :error ->
        nil
    end
  end

  def update_company(company, attrs) do
    company
    |> Company.changeset(attrs)
    |> Repo.update()
  end

  def delete_company(company) do
    Repo.delete(company)
  end

  def get_company_by_slug(slug) when is_binary(slug) do
    Repo.get_by(Company, slug: slug)
  end

  def get_company_by_slug(_slug), do: nil
end
