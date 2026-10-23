defmodule LeadRescueWeb.UserJSON do
  def data(user) do
    %{
      id: user.id,
      company_id: user.company_id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      role: user.role,
      active: user.active,
      confirmed_at: user.confirmed_at
    }
  end
end
