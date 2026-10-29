defmodule LeadRescueWeb.LeadJSON do
  def data(lead) do
    %{
      id: lead.id,
      company_id: lead.company_id,
      name: lead.name,
      email: lead.email,
      phone: lead.phone,
      message: lead.message,
      status: lead.status,
      source: lead.source
    }
  end
end
