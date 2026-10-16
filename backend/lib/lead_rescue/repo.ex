defmodule LeadRescue.Repo do
  use Ecto.Repo,
    otp_app: :lead_rescue,
    adapter: Ecto.Adapters.Postgres
end
