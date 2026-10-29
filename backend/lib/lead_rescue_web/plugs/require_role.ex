defmodule LeadRescueWeb.Plugs.RequireRole do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  def init(options) do
    Keyword.fetch!(options, :roles)
  end

  def call(conn, allowed_roles) do
    current_user = conn.assigns.current_user

    if current_user.role in allowed_roles do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> json(%{
        errors: %{
          detail: "Forbidden"
        }
      })
      |> halt()
    end
  end
end
