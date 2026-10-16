defmodule LeadRescueWeb.CompanyControllerTest do
  use LeadRescueWeb.ConnCase

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
end
