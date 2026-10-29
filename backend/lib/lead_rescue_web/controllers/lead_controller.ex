defmodule LeadRescueWeb.LeadController do
  use LeadRescueWeb, :controller

  alias LeadRescue.Companies
  alias LeadRescue.Leads
  alias LeadRescueWeb.ChangesetJSON
  alias LeadRescueWeb.LeadJSON

  def create(conn, %{"slug" => slug, "lead" => lead_params}) do
    case Companies.get_company_by_slug(slug) do
      nil ->
        company_not_found(conn)

      company ->
        case Leads.create_lead(company, lead_params) do
          {:ok, lead} ->
            conn
            |> put_status(:created)
            |> json(%{data: LeadJSON.data(lead)})

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: ChangesetJSON.errors(changeset)})
        end
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{errors: %{detail: "Missing lead parameters"}})
  end

  defp company_not_found(conn) do
    conn
    |> put_status(:not_found)
    |> json(%{errors: %{detail: "Company not found"}})
  end
end
