defmodule LeadRescue.Onboarding do
  alias Ecto.Multi

  alias LeadRescue.Accounts.User
  alias LeadRescue.Companies.Company
  alias LeadRescue.Repo

  def register_company(attrs) do
    company_attrs = %{
      name: attrs["name"],
      slug: slugify(attrs["name"])
    }

    user_attrs = %{
      email: attrs["admin_email"],
      password: attrs["password"],
      first_name: attrs["admin_first_name"],
      last_name: attrs["admin_last_name"]
    }

    Multi.new()
    |> Multi.insert(
      :company,
      Company.changeset(%Company{}, company_attrs)
    )
    |> Multi.run(:user, fn repo, %{company: company} ->
      %User{
        company_id: company.id,
        role: "company_admin"
      }
      |> User.changeset(user_attrs)
      |> repo.insert()
    end)
    |> Repo.transaction()
  end

  defp slugify(name) when is_binary(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/u, "-")
    |> String.trim("-")
  end

  defp slugify(_name), do: nil
end
