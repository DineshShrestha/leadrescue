defmodule LeadRescue.CompaniesTest do
  use LeadRescue.DataCase

  alias LeadRescue.Companies
  alias LeadRescue.Companies.Company

  describe "create_company/1" do
    test "creates a company with valid attributes" do
      attrs = %{
        name: "Acme AS",
        slug: "acme"
      }

      assert {:ok, %Company{} = company} = Companies.create_company(attrs)
      assert company.name == "Acme AS"
      assert company.slug == "acme"
    end

    test "returns an invalid changeset when required attributes are missing" do
      assert {:error, changeset} = Companies.create_company(%{})

      assert "can't be blank" in errors_on(changeset).name
      assert "can't be blank" in errors_on(changeset).slug
    end
  end

  describe "list companies/0" do
    test "returns all companies" do
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

      companies = Companies.list_companies()

      returned_ids =
        companies
        |> Enum.map(& &1.id)
        |> IO.inspect(label: "ids")
        |> MapSet.new()

      expected_ids = MapSet.new([first_company.id, second_company.id])

      assert returned_ids == expected_ids
    end
  end
end
