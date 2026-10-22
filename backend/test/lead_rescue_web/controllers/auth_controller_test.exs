defmodule LeadRescueWeb.AuthControllerTest do
  use LeadRescueWeb.ConnCase

  alias LeadRescue.Accounts
  alias LeadRescue.Companies

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
end
