defmodule LeadRescueWeb.CompanyController do
  use LeadRescueWeb, :controller
  alias LeadRescue.Companies

  def index(conn, _params) do
    companies = Companies.list_companies()

    json(conn, %{
      data:
        Enum.map(companies, fn company ->
          %{
            id: company.id,
            name: company.name,
            slug: company.slug
          }
        end)
    })
  end

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

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: translate_errors(changeset)})
    end
  end

  def show(conn, %{"id" => id}) do
    case Companies.get_company(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{errors: %{detail: "Company not found"}})

      company ->
        json(conn, %{
          data: %{
            id: company.id,
            name: company.name,
            slug: company.slug
          }
        })
    end
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, options} ->
      Enum.reduce(options, message, fn {key, value}, translated_message ->
        String.replace(translated_message, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
