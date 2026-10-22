defmodule LeadRescueWeb.AuthController do
  use LeadRescueWeb, :controller

  alias LeadRescue.Accounts

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
        token = Phoenix.Token.sign(LeadRescueWeb.Endpoint, "user authentication", user.id)

        json(conn, %{
          token: token,
          user: user_data(user)
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

  defp user_data(user) do
    %{
      id: user.id,
      company_id: user.company_id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      role: user.role,
      active: user.active,
      confirmed_at: user.confirmed_at
    }
  end
end
