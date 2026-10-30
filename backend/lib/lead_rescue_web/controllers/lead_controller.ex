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

  def index(conn, _params) do
    current_user = conn.assigns.current_user
    company = Companies.get_company(current_user.company_id)
    leads = Leads.list_leads(company)

    json(conn, %{data: Enum.map(leads, &LeadJSON.data/1)})
  end

  def show(conn, %{"id" => lead_id}) do
    current_user = conn.assigns.current_user
    company = Companies.get_company(current_user.company_id)

    case Leads.get_lead(company, lead_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{errors: %{detail: "Lead not found"}})

      lead ->
        json(conn, %{data: LeadJSON.data(lead)})
    end
  end

  defp company_not_found(conn) do
    conn
    |> put_status(:not_found)
    |> json(%{errors: %{detail: "Company not found"}})
  end
end
