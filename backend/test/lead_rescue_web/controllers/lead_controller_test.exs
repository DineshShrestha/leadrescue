defmodule LeadRescueWeb.LeadControllerTest do
  use LeadRescueWeb.ConnCase

  alias LeadRescue.Companies

  test "POST /api/public/companies/:slug/leads creates a lead", %{conn: conn} do
    {:ok, company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    params = %{
      lead: %{
        name: "Jane Doe",
        email: "jane@example.com",
        message: "I need help with my project"
      }
    }

    conn = post(conn, "/api/public/companies/#{company.slug}/leads", params)

    assert %{
             "data" => %{
               "id" => lead_id,
               "company_id" => company_id,
               "name" => "Jane Doe",
               "email" => "jane@example.com",
               "phone" => nil,
               "message" => "I need help with my project",
               "status" => "new",
               "source" => "contact_form"
             }
           } = json_response(conn, 201)

    assert is_binary(lead_id)
    assert company_id == company.id
  end

  test "POST /api/public/companies/:slug/leads returns 404 for an unknown company", %{conn: conn} do
    params = %{
      lead: %{
        name: "Jane Doe",
        email: "jane@example.com",
        message: "I need help"
      }
    }

    conn = post(conn, "/api/public/companies/unknown/leads", params)

    assert %{
             "errors" => %{
               "detail" => "Company not found"
             }
           } = json_response(conn, 404)
  end

  test "POST /api/public/companies/:slug/leads returns validation errors", %{conn: conn} do
    {:ok, company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    params = %{
      lead: %{
        name: "",
        email: "invalid email",
        message: ""
      }
    }

    conn = post(conn, "/api/public/companies/#{company.slug}/leads", params)

    assert %{
             "errors" => %{
               "name" => ["can't be blank"],
               "email" => ["has invalid format"],
               "message" => ["can't be blank"]
             }
           } = json_response(conn, 422)
  end

  test "POST /api/public/companies/:slug/leads returns 404 when lead parameters are missing", %{
    conn: conn
  } do
    {:ok, company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    params = %{}

    conn = post(conn, "/api/public/companies/#{company.slug}/leads", params)

    assert %{
             "errors" => %{"detail" => "Missing lead parameters"}
           } = json_response(conn, 400)
  end
end
