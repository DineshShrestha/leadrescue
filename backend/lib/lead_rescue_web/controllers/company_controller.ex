defmodule LeadRescueWeb.CompanyController do
  use LeadRescueWeb, :controller
  alias LeadRescue.Companies

  def create(conn, %{"company" => company_params}) do
    case Companies.create_company(company_params) do
      {:ok, company} ->
        conn
        |> put_status(:created)
        |> json(%{
          data: %{
            id: company.id,
            name: company.name,
            slug: company.slug
          }
        })

      {:error, _changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: %{company: ["is invalid"]}})
    end
  end
end
