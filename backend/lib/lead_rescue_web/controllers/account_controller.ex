defmodule LeadRescueWeb.AccountController do
  use LeadRescueWeb, :controller

  alias LeadRescueWeb.UserJSON

  def show(conn, _params) do
    user = conn.assigns.current_user

    json(conn, %{
      user: UserJSON.data(user)
    })
  end
end
