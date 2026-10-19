defmodule LeadRescueWeb.CompanyControllerTest do
  use LeadRescueWeb.ConnCase

  alias LeadRescue.Companies

  test "POST /api/companies creates a company", %{conn: conn} do
    params = %{
      company: %{
        name: "Acme AS",
        slug: "acme"
      }
    }

    conn = post(conn, ~p"/api/companies", params)

    assert %{
             "data" => %{
               "id" => id,
               "name" => "Acme AS",
               "slug" => "acme"
             }
           } = json_response(conn, 201)

    assert is_binary(id)
  end

  test "POST /api/companies returns validation errors for invalid parameters", %{conn: conn} do
    params = %{
      company: %{}
    }

    conn = post(conn, ~p"/api/companies", params)

    assert %{
             "errors" => %{
               "name" => ["can't be blank"],
               "slug" => ["can't be blank"]
             }
           } = json_response(conn, 422)
  end

  test "GET /api/companies returns all companies", %{conn: conn} do
    {:ok, first_company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    {:ok, second_company} =
      Companies.create_company(%{
        name: "Wayne Enterprises",
        slug: "wayne"
      })

    conn = get(conn, ~p"/api/companies")

    assert %{"data" => companies} = json_response(conn, 200)

    returned_ids =
      companies
      |> Enum.map(& &1["id"])
      |> MapSet.new()

    expected_ids = MapSet.new([first_company.id, second_company.id])

    assert returned_ids == expected_ids
  end
end
