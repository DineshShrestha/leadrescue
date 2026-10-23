defmodule LeadRescueWeb.Plugs.AuthenticateUser do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  alias LeadRescue.Accounts
  alias LeadRescue.Accounts.User
  alias LeadRescueWeb.AuthToken

  def init(options), do: options

  def call(conn, _options) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user_id} <- AuthToken.verify(token),
         %User{} = user <- Accounts.get_user(user_id) do
      assign(conn, :current_user, user)
    else
      _result -> unauthorized(conn)
    end
  end

  defp unauthorized(conn) do
    conn
    |> put_status(:unauthorized)
    |> json(%{
      errors: %{
        detail: "Unauthorized"
      }
    })
    |> halt()
  end
end
