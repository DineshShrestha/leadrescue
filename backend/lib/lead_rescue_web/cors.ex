defmodule LeadRescueWeb.CORS do
  def allowed_origins do
    Application.fetch_env!(:lead_rescue, :cors_origins)
  end
end
