defmodule LeadRescue.AccountsTest do
  use LeadRescue.DataCase

  alias LeadRescue.Accounts
  alias LeadRescue.Accounts.User
  alias LeadRescue.Companies
  alias LeadRescue.Repo

  describe "create_user/2" do
    test "creates a company user with valid attributes" do
      {:ok, company} =
        Companies.create_company(%{
          name: "Acme AS",
          slug: "acme"
        })

      attrs = %{
        email: "user@example.com",
        password: "password123",
        first_name: "Ada",
        last_name: "Lovelace"
      }

      assert {:ok, %User{} = user} = Accounts.create_user(company, attrs)

      assert user.company_id == company.id
      assert user.role == "company_user"
      assert user.password == nil
      assert is_binary(user.hashed_password)
      assert Bcrypt.verify_pass("password123", user.hashed_password)
    end

    test "returns an invalid changeset for invalid attributes" do
      {:ok, company} =
        Companies.create_company(%{
          name: "Acme AS",
          slug: "acme"
        })

      attrs = %{
        email: "invalid-email",
        password: "short",
        first_name: "",
        last_name: ""
      }

      assert {:error, changeset} = Accounts.create_user(company, attrs)

      errors = errors_on(changeset)

      assert "has invalid format" in errors.email
      assert "should be at least 8 character(s)" in errors.password
      assert "can't be blank" in errors.first_name
      assert "can't be blank" in errors.last_name
    end

    test "ignores client-supplied company and role" do
      {:ok, company} =
        Companies.create_company(%{
          name: "Acme AS",
          slug: "acme"
        })

      {:ok, other_company} =
        Companies.create_company(%{
          name: "Other AS",
          slug: "other"
        })

      attrs = %{
        email: "user@example.com",
        password: "password123",
        first_name: "Ada",
        last_name: "Lovelace",
        company_id: other_company.id,
        role: "super_admin"
      }

      assert {:ok, user} = Accounts.create_user(company, attrs)

      assert user.company_id == company.id
      assert user.role == "company_user"
    end
  end

  describe "get_user_by_email_and_password/2" do
    setup do
      {:ok, company} =
        Companies.create_company(%{
          name: "Acme AS",
          slug: "acme"
        })

      password = "password123"

      {:ok, user} =
        Accounts.create_user(company, %{
          email: "user@example.com",
          password: password,
          first_name: "Ada",
          last_name: "Lovelace"
        })

      %{user: user, password: password}
    end

    test "returns the user for a valid email and password", %{user: user, password: password} do
      authenticated_user = Accounts.get_user_by_email_and_password(user.email, password)

      assert %User{} = authenticated_user
      assert authenticated_user.id == user.id
    end

    test "returns nil for an incorrect password", %{user: user} do
      assert Accounts.get_user_by_email_and_password(user.email, "wrong-password") == nil
    end

    test "returns nil for an unknown email", %{password: password} do
      assert Accounts.get_user_by_email_and_password("unknown@example.com", password) == nil
    end

    test "returns nil for an inactive user", %{user: user, password: password} do
      user
      |> Ecto.Changeset.change(active: false)
      |> Repo.update!()

      assert Accounts.get_user_by_email_and_password(user.email, password) == nil
    end
  end

  describe "get_user/1" do
    test "returns the user for the existing ID" do
      {:ok, company} =
        Companies.create_company(%{
          name: "Acme AS",
          slug: "acme"
        })

      {:ok, created_user} =
        Accounts.create_user(company, %{
          email: "user@example.com",
          password: "password123",
          first_name: "Ada",
          last_name: "Lovelace"
        })

      returned_user = Accounts.get_user(created_user.id)

      assert %User{} = returned_user
      assert returned_user.id == created_user.id
      assert returned_user.email == created_user.email
    end

    test "returns nil when the user does not exist" do
      missing_id = Ecto.UUID.generate()

      returned_user = Accounts.get_user(missing_id)

      assert returned_user == nil
    end

    test "returns nil for a malformed user ID" do
      returned_user = Accounts.get_user("not-a-uuid")

      assert returned_user == nil
    end
  end
end
