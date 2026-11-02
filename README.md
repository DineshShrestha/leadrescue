# JobRelay / LeadRescue

LeadRescue is a small lead-intake and follow-up application for service businesses. A company gets a public customer form and an authenticated inbox where staff can review and qualify incoming enquiries.

## MVP features

- Company registration and authenticated sessions
- Public, company-branded lead form at `/r/:companySlug`
- Company-scoped lead inbox with newest-first ordering and status filters
- Lead detail view with email/phone actions and status management
- Company profile settings and a copyable public intake link

## Local development

Requirements: Elixir, Erlang, PostgreSQL, and Node.js.

Start the API:

```bash
cd backend
mix setup
mix phx.server
```

In another terminal, start the frontend:

```bash
cd frontend
cp .env.example .env
npm install
npm run dev
```

Open [http://localhost:5173](http://localhost:5173). The API runs at [http://localhost:4000](http://localhost:4000).

## Verification

```bash
cd backend && mix test
cd frontend && npm run lint && npm run build
```

## Production configuration

The backend requires `DATABASE_URL`, `SECRET_KEY_BASE`, `PHX_HOST`, and `CORS_ORIGINS`. The frontend requires `VITE_API_URL` at build time.

Billing and outbound password-reset email are not part of the current MVP.
