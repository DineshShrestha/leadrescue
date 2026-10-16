defmodule LeadRescueWeb.HealthContoller do
    use LeadRescueWeb, :controller

    def show(conn, _params) do
        json(conn, %{status: "ok"})
    end
end