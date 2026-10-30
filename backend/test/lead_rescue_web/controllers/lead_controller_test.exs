defmodule LeadRescueWeb.LeadControllerTest do
  use LeadRescueWeb.ConnCase

  alias LeadRescue.Companies
  alias LeadRescue.Accounts
  alias LeadRescueWeb.AuthToken
  alias LeadRescue.Leads

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

  test "GET /api/leads returns only the authenticated user's company leads", %{conn: conn} do
    {:ok, company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    {:ok, other_company} =
      Companies.create_company(%{
        name: "Wayne Enterprises",
        slug: "wayne"
      })

    {:ok, user} =
      Accounts.create_user(company, %{
        email: "user@example.com",
        password: "password1234",
        first_name: "Ada",
        last_name: "Lovelace"
      })

    {:ok, own_lead} =
      Leads.create_lead(company, %{
        name: "Jane Doe",
        email: "jane@example.com",
        message: "I need help"
      })

    {:ok, _other_lead} =
      Leads.create_lead(other_company, %{
        name: "Bruce Wayne",
        email: "bruce@example.com",
        message: "Another enquiry"
      })

    token = AuthToken.sign(user)

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> get(~p"/api/leads")

    assert %{"data" => leads} = json_response(conn, 200)

    assert Enum.map(leads, & &1["id"]) == [own_lead.id]
  end

  test "GET /api/leads retuns 401 without authentication", %{conn: conn} do
    conn = get(conn, ~p"/api/leads")

    assert %{
             "errors" => %{
               "detail" => "Unauthorized"
             }
           } = json_response(conn, 401)
  end

  test "GET /api/leads/:id returns a lead belonging to the authenticated user's company", %{
    conn: conn
  } do
    {:ok, company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    {:ok, user} =
      Accounts.create_user(company, %{
        email: "user@example.com",
        password: "password1234",
        first_name: "Ada",
        last_name: "Lovelace"
      })

    {:ok, lead} =
      Leads.create_lead(company, %{
        name: "Jane Doe",
        email: "jane@example.com",
        message: "I need help"
      })

    token = AuthToken.sign(user)

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> get(~p"/api/leads/#{lead.id}")

    assert %{
             "data" => %{
               "id" => lead_id,
               "company_id" => company_id,
               "name" => "Jane Doe"
             }
           } = json_response(conn, 200)

    assert lead_id == lead.id
    assert company_id == company.id
  end

  test "GET /api/leads/:id returns 404 for another company's lead", %{conn: conn} do
    {:ok, first_company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    {:ok, second_company} =
      Companies.create_company(%{
        name: "Sayne Enterprises",
        slug: "wayne"
      })

    {:ok, first_company_user} =
      Accounts.create_user(first_company, %{
        email: "user@example.com",
        password: "password1234",
        first_name: "Ada",
        last_name: "Lovelace"
      })

    {:ok, second_company_lead} =
      Leads.create_lead(second_company, %{
        name: "Bruce Wayne",
        email: "bruce@example.com",
        message: "Private enquiry"
      })

    token = AuthToken.sign(first_company_user)

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> get(~p"/api/leads/#{second_company_lead.id}")

    assert %{
             "errors" => %{
               "detail" => "Lead not found"
             }
           } = json_response(conn, 404)
  end
end
