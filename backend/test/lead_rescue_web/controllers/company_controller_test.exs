defmodule LeadRescueWeb.CompanyControllerTest do
  use LeadRescueWeb.ConnCase

  alias LeadRescue.Accounts.User
  alias LeadRescue.Companies
  alias LeadRescue.Repo
  alias LeadRescueWeb.AuthToken
  alias LeadRescue.Accounts

  setup %{conn: conn} do
    {:ok, super_admin} =
      %User{role: "super_admin"}
      |> User.changeset(%{
        email: "admin@example.com",
        password: "password1234",
        first_name: "Super",
        last_name: "Admin"
      })
      |> Repo.insert()

    token = AuthToken.sign(super_admin)

    authenticated_conn =
      put_req_header(conn, "authorization", "Bearer #{token}")

    %{conn: authenticated_conn}
  end

  test "POST /api/companies creates a company", %{conn: conn} do
    params = %{
      company: %{
        name: "Acme AS",
        slug: "acme"
      }
    }

    conn = post(conn, ~p"/api/companies", params)

    assert %{
             "data" => %{
               "id" => id,
               "name" => "Acme AS",
               "slug" => "acme"
             }
           } = json_response(conn, 201)

    assert is_binary(id)
  end

  test "POST /api/companies returns validation errors for invalid parameters", %{conn: conn} do
    params = %{
      company: %{}
    }

    conn = post(conn, ~p"/api/companies", params)

    assert %{
             "errors" => %{
               "name" => ["can't be blank"],
               "slug" => ["can't be blank"]
             }
           } = json_response(conn, 422)
  end

  test "POST /api/companies returns an error when the slug already exists", %{conn: conn} do
    assert {:ok, _existing_company} =
             Companies.create_company(%{
               name: "Acme AS",
               slug: "acme"
             })

    params = %{
      company: %{
        name: "Another company",
        slug: "acme"
      }
    }

    conn = post(conn, ~p"/api/companies", params)

    assert %{
             "errors" => %{
               "slug" => ["has already been taken"]
             }
           } = json_response(conn, 422)
  end

  test "POST /api/companies returns 400 when company parameters are missing", %{conn: conn} do
    conn = post(conn, ~p"/api/companies", %{})

    assert %{
             "errors" => %{
               "detail" => "Missing company parameters"
             }
           } = json_response(conn, 400)
  end

  test "GET /api/companies returns all companies", %{conn: conn} do
    {:ok, first_company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    {:ok, second_company} =
      Companies.create_company(%{
        name: "Wayne Enterprises",
        slug: "wayne"
      })

    conn = get(conn, ~p"/api/companies")

    assert %{"data" => companies} = json_response(conn, 200)

    returned_ids =
      companies
      |> Enum.map(& &1["id"])
      |> MapSet.new()

    expected_ids = MapSet.new([first_company.id, second_company.id])

    assert returned_ids == expected_ids
  end

  test "GET /api/companies/:id returns the company", %{conn: conn} do
    {:ok, company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    conn = get(conn, ~p"/api/companies/#{company.id}")

    assert %{
             "data" => %{
               "id" => id,
               "name" => "Acme AS",
               "slug" => "acme"
             }
           } = json_response(conn, 200)

    assert id == company.id
  end

  test "GET /api/companies/:id returns 404 when the company does not exist", %{conn: conn} do
    missing_id = Ecto.UUID.generate()

    conn = get(conn, ~p"/api/companies/#{missing_id}")

    assert %{
             "errors" => %{
               "detail" => "Company not found"
             }
           } = json_response(conn, 404)
  end

  test "GET /api/companies/:id returns 404 for a malformed ID", %{conn: conn} do
    invalid_id = "not-a-uuid"

    conn = get(conn, ~p"/api/companies/#{invalid_id}")

    assert %{
             "errors" => %{
               "detail" => "Company not found"
             }
           } = json_response(conn, 404)
  end

  test "PUT /api/companies/:id updates the company", %{conn: conn} do
    {:ok, company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    params = %{
      company: %{
        name: "Updated AS",
        slug: "updated"
      }
    }

    conn = put(conn, ~p"/api/companies/#{company.id}", params)

    assert %{
             "data" => %{
               "id" => id,
               "name" => "Updated AS",
               "slug" => "updated"
             }
           } = json_response(conn, 200)

    assert id == company.id
  end

  test "PUT /api/companies/:id returns validation errors for invalid parameters", %{conn: conn} do
    {:ok, company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    params = %{
      company: %{
        name: "",
        slug: ""
      }
    }

    conn = put(conn, ~p"/api/companies/#{company.id}", params)

    assert %{
             "errors" => %{
               "name" => ["can't be blank"],
               "slug" => ["can't be blank"]
             }
           } = json_response(conn, 422)
  end

  test "PUT /api/companies/:id returns 404 when the company does not exist", %{conn: conn} do
    missing_id = Ecto.UUID.generate()

    params = %{
      company: %{
        name: "Updated AS",
        slug: "updated"
      }
    }

    conn = put(conn, ~p"/api/companies/#{missing_id}", params)

    assert %{
             "errors" => %{
               "detail" => "Company not found"
             }
           } = json_response(conn, 404)
  end

  test "PUT /api/companies/:id returns 400 when company parameters are missing", %{conn: conn} do
    {:ok, company} = Companies.create_company(%{name: "Acme AS", slug: "acme"})

    conn = put(conn, ~p"/api/companies/#{company.id}", %{})

    assert %{
             "errors" => %{
               "detail" => "Missing company parameters"
             }
           } = json_response(conn, 400)
  end

  test "DELETE /api/companies/:id deletes the company", %{conn: conn} do
    {:ok, company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    conn = delete(conn, ~p"/api/companies/#{company.id}")

    assert response(conn, 204) == ""
    assert Companies.get_company(company.id) == nil
  end

  test "DELETE /api/companies/:id returns 404 when the company does not exist", %{conn: conn} do
    missing_id = Ecto.UUID.generate()

    conn = delete(conn, ~p"/api/companies/#{missing_id}")

    assert %{
             "errors" => %{
               "detail" => "Company not found"
             }
           } = json_response(conn, 404)
  end

  test "GET /api/companies returns 401 without authentication" do
    conn =
      build_conn()
      |> get(~p"/api/companies")

    assert %{
             "errors" => %{
               "detail" => "Unauthorized"
             }
           } = json_response(conn, 401)
  end

  test "GET /api/companies returns 403 for a company user" do
    {:ok, company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    {:ok, company_user} =
      Accounts.create_user(company, %{
        email: "user@example.com",
        password: "password1234",
        first_name: "Ada",
        last_name: "Lovelace"
      })

    token = AuthToken.sign(company_user)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> get(~p"/api/companies")

    assert %{
             "errors" => %{
               "detail" => "Forbidden"
             }
           } = json_response(conn, 403)
  end

  test "GET /api/companies/:id returns 403 for a user from another company" do
    {:ok, own_company} =
      Companies.create_company(%{
        name: "Own Company",
        slug: "own-company"
      })

    {:ok, other_company} =
      Companies.create_company(%{
        name: "Other Company",
        slug: "other-company"
      })

    {:ok, company_user} =
      Accounts.create_user(own_company, %{
        email: "user@example.com",
        password: "password1234",
        first_name: "Ada",
        last_name: "Lovelace"
      })

    token = AuthToken.sign(company_user)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> get(~p"/api/companies/#{other_company.id}")

    assert %{
             "errors" => %{
               "detail" => "Forbidden"
             }
           } = json_response(conn, 403)
  end

  test "GET /api/companies/:id returns the user's own company" do
    {:ok, company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    {:ok, company_user} =
      Accounts.create_user(company, %{
        email: "user@example.com",
        password: "password1234",
        first_name: "Ada",
        last_name: "Lovelace"
      })

    token = AuthToken.sign(company_user)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> get(~p"/api/companies/#{company.id}")

    assert %{
             "data" => %{
               "id" => returned_id,
               "name" => "Acme AS",
               "slug" => "acme"
             }
           } = json_response(conn, 200)

    assert returned_id == company.id
  end

  test "PUT /api/companies/:id returns 403 for a company user" do
    {:ok, company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    {:ok, company_user} =
      Accounts.create_user(company, %{
        email: "user@example.com",
        password: "password1234",
        first_name: "Ada",
        last_name: "Lovelace"
      })

    token = AuthToken.sign(company_user)

    params = %{
      company: %{
        name: "Changed Company",
        slug: "changed-company"
      }
    }

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> put(~p"/api/companies/#{company.id}", params)

    assert %{
             "errors" => %{
               "detail" => "Forbidden"
             }
           } = json_response(conn, 403)

    unchanged_company = Companies.get_company(company.id)

    assert unchanged_company.name == "Acme AS"
    assert unchanged_company.slug == "acme"
  end

  test "PUT /api/companies/:id allows a company admin to update their own company" do
    {:ok, company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    {:ok, company_admin} =
      %User{
        company_id: company.id,
        role: "company_admin"
      }
      |> User.changeset(%{
        email: "admin@acme.example",
        password: "password1234",
        first_name: "Ada",
        last_name: "Admin"
      })
      |> Repo.insert()

    token = AuthToken.sign(company_admin)

    params = %{
      company: %{
        name: "Updated Acme AS",
        slug: "updated-acme"
      }
    }

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> put(~p"/api/companies/#{company.id}", params)

    assert %{
             "data" => %{
               "id" => returned_id,
               "name" => "Updated Acme AS",
               "slug" => "updated-acme"
             }
           } = json_response(conn, 200)

    assert returned_id == company.id
  end

  test "PUT /api/companies/:id returns 403 when a company admin updates another company" do
    {:ok, own_company} =
      Companies.create_company(%{
        name: "Own Company",
        slug: "own-company"
      })

    {:ok, other_company} =
      Companies.create_company(%{
        name: "Other Company",
        slug: "other-company"
      })

    {:ok, company_admin} =
      %User{
        company_id: own_company.id,
        role: "company_admin"
      }
      |> User.changeset(%{
        email: "admin@own.example",
        password: "password1234",
        first_name: "Ada",
        last_name: "Lovelace"
      })
      |> Repo.insert()

    token = AuthToken.sign(company_admin)

    params = %{
      company: %{
        name: "Illegally Changed",
        slug: "illegally-changed"
      }
    }

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> put(~p"/api/companies/#{other_company.id}", params)

    assert %{
             "errors" => %{
               "detail" => "Forbidden"
             }
           } = json_response(conn, 403)

    unchanged_company = Companies.get_company(other_company.id)

    assert unchanged_company.name == "Other Company"
    assert unchanged_company.slug == "other-company"
  end
end
