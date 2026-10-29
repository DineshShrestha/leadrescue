defmodule LeadRescueWeb.CORSTest do
  use LeadRescueWeb.ConnCase

  test "allows preflight requests from the frontend origin", %{conn: conn} do
    conn =
      conn
      |> put_req_header("origin", "http://localhost:5173")
      |> put_req_header("access-control-request-method", "POST")
      |> options("/api/auth/login")

    assert get_resp_header(conn, "access-control-allow-origin") ==
             ["http://localhost:5173"]
  end
end
