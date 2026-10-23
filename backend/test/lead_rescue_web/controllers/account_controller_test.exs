defmodule LeadRescueWeb.AccountControllerTest do
  use LeadRescueWeb.ConnCase
  alias LeadRescue.Companies
  alias LeadRescue.Accounts
  alias LeadRescueWeb.AuthToken
  alias LeadRescue.Accounts.User

  test "GET /api/account returns 401 without authentication token", %{conn: conn} do
    conn = get(conn, ~p"/api/account")

    assert %{
             "errors" => %{
               "detail" => "Unauthorized"
             }
           } = json_response(conn, 401)
  end

  test "GET /api/account returns the authenticated user", %{conn: conn} do
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

    token = AuthToken.sign(user)

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> get(~p"/api/account")

    assert %{
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

    assert user_id == user.id
    assert company_id == company.id
  end

  test "GET /api/account returns 401 for an invalid token", %{conn: conn} do
    conn =
      conn
      |> put_req_header("authorization", "Bearer invalid-token")
      |> get(~p"/api/account")

    assert %{
             "errors" => %{
               "detail" => "Unauthorized"
             }
           } = json_response(conn, 401)
  end

  test "GET /api/account returns 401 when the token user does not exist", %{conn: conn} do
    missing_user = %User{id: Ecto.UUID.generate()}
    token = AuthToken.sign(missing_user)

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> get(~p"/api/account")

    assert %{
             "errors" => %{
               "detail" => "Unauthorized"
             }
           } = json_response(conn, 401)
  end
end
