defmodule LeadRescueWeb.AuthControllerTest do
  use LeadRescueWeb.ConnCase

  alias LeadRescue.Accounts
  alias LeadRescue.Companies
  alias LeadRescue.Onboarding

  test "POST /api/auth/login returns a token and user for valid credentials", %{conn: conn} do
    {:ok, company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    password = "password123"

    {:ok, user} =
      Accounts.create_user(company, %{
        email: "user@example.com",
        password: password,
        first_name: "Ada",
        last_name: "Lovelace"
      })

    params = %{
      email: user.email,
      password: password
    }

    conn = post(conn, "/api/auth/login", params)

    assert %{
             "token" => token,
             "user" => %{
               "id" => user_id,
               "company_id" => company_id,
               "email" => "user@example.com",
               "first_name" => "Ada",
               "last_name" => "Lovelace",
               "role" => "company_user",
               "active" => true,
               "confirmed_at" => nil
             }
           } = json_response(conn, 200)

    assert is_binary(token)
    assert user_id == user.id
    assert company_id == company.id
  end

  test "POST /api/auth/login returns 401 for an incorrect password", %{conn: conn} do
    {:ok, company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    {:ok, user} =
      Accounts.create_user(company, %{
        email: "user@example.com",
        password: "password123",
        first_name: "Ada",
        last_name: "Lovelace"
      })

    params = %{
      email: user.email,
      password: "wrong-password"
    }

    conn = post(conn, ~p"/api/auth/login", params)

    assert %{
             "errors" => %{
               "detail" => "Invalid email or password"
             }
           } = json_response(conn, 401)
  end

  test "POST /api/auth/login returns 401 for an unknown email", %{conn: conn} do
    params = %{
      email: "unknown@example.com",
      password: nil
    }

    conn = post(conn, ~p"/api/auth/login", params)

    assert %{
             "errors" => %{
               "detail" => "Invalid email or password"
             }
           } = json_response(conn, 401)
  end

  test "POST /api/auth/login returns 400 when credentials are missing", %{conn: conn} do
    params = %{}

    conn = post(conn, ~p"/api/auth/login", params)

    assert %{
             "errors" => %{
               "detail" => "Email and password are required"
             }
           } = json_response(conn, 400)
  end

  test "DELETE /api/auth/logout returns no content", %{conn: conn} do
    conn = delete(conn, "/api/auth/logout")

    assert response(conn, 204) == ""
  end

  test "POST /api/auth/register creates a company and administrator", %{conn: conn} do
    params = %{
      name: "Acme AS",
      admin_first_name: "Ada",
      admin_last_name: "Lovelace",
      admin_email: "ada@example.com",
      password: "password1234"
    }

    conn = post(conn, ~p"/api/auth/register", params)

    assert %{
             "company" => %{
               "id" => company_id,
               "name" => "Acme AS",
               "slug" => "acme-as"
             },
             "user" => %{
               "id" => user_id,
               "company_id" => returned_company_id,
               "email" => "ada@example.com",
               "first_name" => "Ada",
               "last_name" => "Lovelace",
               "role" => "company_admin",
               "active" => true,
               "confirmed_at" => nil
             }
           } = json_response(conn, 201)

    assert is_binary(company_id)
    assert is_binary(user_id)
    assert returned_company_id == company_id
  end

  test "POST /api/auth/register returns validation errors for invalid parameters", %{conn: conn} do
    params = %{
      name: "Acme AS",
      admin_first_name: "",
      admin_last_name: "",
      admin_email: "invalid_email",
      password: "short"
    }

    conn = post(conn, ~p"/api/auth/register", params)

    assert %{
             "errors" => %{
               "email" => ["has invalid format"],
               "password" => ["should be at least 8 character(s)"],
               "first_name" => ["can't be blank"],
               "last_name" => ["can't be blank"]
             }
           } = json_response(conn, 422)
  end

  test "POST /api/auth/register rejects an existing email", %{conn: conn} do
    assert {:ok, _registration} =
             Onboarding.register_company(%{
               "name" => "First Company",
               "admin_first_name" => "Ada",
               "admin_last_name" => "Lovelace",
               "admin_email" => "ada@example.com",
               "password" => "password1234"
             })

    params = %{
      name: "Second Company",
      admin_first_name: "Grace",
      admin_last_name: "Hopper",
      admin_email: "ada@example.com",
      password: "password5678"
    }

    conn = post(conn, ~p"/api/auth/register", params)

    assert %{
             "errors" => %{
               "email" => ["has already been taken"]
             }
           } = json_response(conn, 422)
  end
end
