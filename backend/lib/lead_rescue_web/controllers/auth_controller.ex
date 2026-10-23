defmodule LeadRescueWeb.AuthController do
  use LeadRescueWeb, :controller

  alias LeadRescue.Accounts
  alias LeadRescueWeb.AuthToken
  alias LeadRescueWeb.UserJSON

  def login(conn, %{"email" => email, "password" => password}) do
    user = Accounts.get_user_by_email_and_password(email, password)

    case user do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          errors: %{
            detail: "Invalid email or password"
          }
        })

      user ->
        token = AuthToken.sign(user)

        json(conn, %{
          token: token,
          user: UserJSON.data(user)
        })
    end
  end

  def login(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      errors: %{
        detail: "Email and password are required"
      }
    })
  end
end
