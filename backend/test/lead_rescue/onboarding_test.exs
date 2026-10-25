defmodule LeadRescue.OnboardingTest do
  use LeadRescue.DataCase

  alias LeadRescue.Accounts.User
  alias LeadRescue.Companies.Company
  alias LeadRescue.Onboarding
  alias LeadRescue.Repo

  test "register_company/1 creates a company and its administrator" do
    attrs =
      %{
        "name" => "Acme AS",
        "admin_first_name" => "Ada",
        "admin_last_name" => "Lovelace",
        "admin_email" => "ada@example.com",
        "password" => "password1234"
      }

    assert {:ok, %{company: %Company{} = company, user: %User{} = user}} =
             Onboarding.register_company(attrs)

    assert company.name == "Acme AS"
    assert company.slug == "acme-as"

    assert user.company_id == company.id
    assert user.email == "ada@example.com"
    assert user.first_name == "Ada"
    assert user.last_name == "Lovelace"
    assert user.role == "company_admin"
    assert user.password == nil
    assert Bcrypt.verify_pass("password1234", user.hashed_password)
  end

  test "register_company/1 rolls back the company when the administrator is invalid" do
    attrs = %{
      "name" => "Acme AS",
      "admin_first_name" => "Ada",
      "admin_last_name" => "Lovelace",
      "admin_email" => "invalid_email",
      "password" => "short"
    }

    assert {:error, :user, changeset, %{company: company}} =
             Onboarding.register_company(attrs)

    errors = errors_on(changeset)

    assert "has invalid format" in errors.email
    assert "should be at least 8 character(s)" in errors.password
    assert Repo.get(Company, company.id) == nil
    assert Repo.get_by(Company, slug: "acme-as") == nil
  end
end
