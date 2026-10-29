defmodule LeadRescueWeb.AuthController do
  use LeadRescueWeb, :controller

  alias LeadRescue.Accounts
  alias LeadRescueWeb.AuthToken
  alias LeadRescueWeb.UserJSON
  alias LeadRescue.Onboarding
  alias LeadRescueWeb.ChangesetJSON

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

  def logout(conn, _params) do
    send_resp(conn, :no_content, "")
  end

  def register(conn, params) do
    case Onboarding.register_company(params) do
      {:ok, %{company: company, user: user}} ->
        conn
        |> put_status(:created)
        |> json(%{
          company: %{
            id: company.id,
            name: company.name,
            slug: company.slug
          },
          user: UserJSON.data(user)
        })

      {:error, _operation, changeset, _completed_operations} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          errors: ChangesetJSON.errors(changeset)
        })
    end
  end
end
