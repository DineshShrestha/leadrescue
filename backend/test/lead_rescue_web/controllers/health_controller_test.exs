defmodule LeadRescueWeb.HealthControllerTest do
  use LeadRescueWeb.ConnCase

  test "GET /health returns an OK response", %{conn: conn} do
    conn = get(conn, ~p"/health")

    assert json_response(conn, 200) == %{"status" => "ok"}
  end
end
