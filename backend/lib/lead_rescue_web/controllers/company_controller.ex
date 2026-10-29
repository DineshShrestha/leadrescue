defmodule LeadRescueWeb.CompanyController do
  use LeadRescueWeb, :controller
  alias LeadRescue.Companies
  alias LeadRescueWeb.ChangesetJSON

  def index(conn, _params) do
    companies = Companies.list_companies()

    json(conn, %{
      data: Enum.map(companies, &company_data/1)
    })
  end

  def create(conn, %{"company" => company_params}) do
    case Companies.create_company(company_params) do
      {:ok, company} ->
        conn
        |> put_status(:created)
        |> json(%{data: company_data(company)})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: ChangesetJSON.errors(changeset)})
    end
  end

  def create(conn, _params) do
    missing_company_params(conn)
  end

  def show(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user

    case Companies.get_company(id) do
      nil ->
        not_found(conn)

      company ->
        if can_view_company?(current_user, company) do
          json(conn, %{data: company_data(company)})
        else
          forbidden(conn)
        end
    end
  end

  def update(conn, %{"id" => id, "company" => company_params}) do
    current_user = conn.assigns.current_user

    case Companies.get_company(id) do
      nil ->
        not_found(conn)

      company ->
        if can_update_company?(current_user, company) do
          case Companies.update_company(company, company_params) do
            {:ok, updated_company} ->
              json(conn, %{
                data: company_data(updated_company)
              })

            {:error, changeset} ->
              conn
              |> put_status(:unprocessable_entity)
              |> json(%{errors: ChangesetJSON.errors(changeset)})
          end
        else
          forbidden(conn)
        end
    end
  end

  def update(conn, _params) do
    missing_company_params(conn)
  end

  def delete(conn, %{"id" => id}) do
    case Companies.get_company(id) do
      nil ->
        not_found(conn)

      company ->
        case Companies.delete_company(company) do
          {:ok, _deleted_company} ->
            send_resp(conn, :no_content, "")

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: ChangesetJSON.errors(changeset)})
        end
    end
  end

  defp company_data(company) do
    %{id: company.id, name: company.name, slug: company.slug}
  end

  defp not_found(conn) do
    conn
    |> put_status(:not_found)
    |> json(%{errors: %{detail: "Company not found"}})
  end

  defp missing_company_params(conn) do
    conn
    |> put_status(:bad_request)
    |> json(%{errors: %{detail: "Missing company parameters"}})
  end

  defp can_view_company?(%{role: "super_admin"}, _company), do: true

  defp can_view_company?(user, company) do
    user.company_id == company.id
  end

  defp forbidden(conn) do
    conn
    |> put_status(:forbidden)
    |> json(%{errors: %{detail: "Forbidden"}})
  end

  defp can_update_company?(%{role: "super_admin"}, _company), do: true

  defp can_update_company?(%{role: "company_admin"} = user, company) do
    user.company_id == company.id
  end

  defp can_update_company?(_user, _company), do: false
end
