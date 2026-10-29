defmodule LeadRescue.LeadsTest do
  use LeadRescue.DataCase

  alias LeadRescue.Companies
  alias LeadRescue.Leads
  alias LeadRescue.Leads.Lead

  test "create_lead/2 creates a lead for the trusted company" do
    {:ok, company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    clinet_company_id = Ecto.UUID.generate()

    attrs = %{
      name: "Jane Doe",
      email: "jane@example.com",
      message: "I need help with my projects",
      company_id: clinet_company_id,
      status: "won",
      source: "untrusted"
    }

    assert {:ok, %Lead{} = lead} =
             Leads.create_lead(company, attrs)

    assert lead.company_id == company.id
    assert lead.company_id != clinet_company_id
    assert lead.status == "new"
    assert lead.source == "contact_form"
    assert lead.phone == nil
  end

  test "create_lead/2 returns validation errors for invalid attributes" do
    {:ok, company} =
      Companies.create_company(%{
        name: "Acme AS",
        slug: "acme"
      })

    attrs = %{
      name: "",
      email: "invalid-email",
      message: ""
    }

    assert {:error, changeset} = Leads.create_lead(company, attrs)

    errors = errors_on(changeset)

    assert "can't be blank" in errors.name
    assert "has invalid format" in errors.email
    assert "can't be blank" in errors.message
  end
end
