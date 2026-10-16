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
end
