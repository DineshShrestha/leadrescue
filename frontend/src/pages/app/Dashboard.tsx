import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { apiRequest } from "../../lib/api";
import type { Lead } from "../../types/lead";
import { StatusBadge } from "./LeadDetail";

export default function Dashboard() {
  const [leads, setLeads] = useState<Lead[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [status, setStatus] = useState<Lead["status"] | "all">("all");

  useEffect(() => {
    apiRequest<{ data: Lead[] }>("/api/leads")
      .then(({ data }) => setLeads(data))
      .catch(() => setError("Kunne ikke hente henvendelser."))
      .finally(() => setLoading(false));
  }, []);

  const visibleLeads =
    status === "all" ? leads : leads.filter((lead) => lead.status === status);
  const newCount = leads.filter((lead) => lead.status === "new").length;

  return (
    <div>
      <h1 className="text-xl font-semibold text-slate-900">Oversikt</h1>
      <p className="mt-2 text-slate-600">
        Se og følg opp innkomne kundehenvendelser.
      </p>
      {!loading && !error && leads.length > 0 && (
        <div className="mt-6 flex flex-wrap items-center justify-between gap-4">
          <div className="flex gap-3 text-sm">
            <span className="rounded-md bg-white px-3 py-2 shadow-sm">
              <strong>{leads.length}</strong> totalt
            </span>
            <span className="rounded-md bg-white px-3 py-2 shadow-sm">
              <strong>{newCount}</strong> nye
            </span>
          </div>
          <label className="text-sm text-slate-600">
            Vis:{" "}
            <select
              value={status}
              onChange={(event) =>
                setStatus(event.target.value as Lead["status"] | "all")
              }
              className="ml-2 rounded-md border border-slate-300 bg-white px-3 py-2 text-slate-900"
            >
              <option value="all">Alle</option>
              <option value="new">Nye</option>
              <option value="contacted">Kontaktet</option>
              <option value="qualified">Kvalifisert</option>
              <option value="won">Vunnet</option>
              <option value="lost">Tapt</option>
            </select>
          </label>
        </div>
      )}
      {loading && <p className="mt-6 text-slate-500">Laster henvendelser...</p>}
      {error && (
        <p role="alert" className="mt-6 text-red-600">
          {error}
        </p>
      )}
      {!loading && !error && leads.length === 0 && (
        <p className="mt-6 rounded-md border border-dashed border-slate-300 p-6 text-slate-500">
          Ingen henvendelser ennå. Del LeadRescue-lenken din med en kunde, eller
          send en test-henvendelse.
        </p>
      )}
      {leads.length > 0 && visibleLeads.length === 0 && (
        <p className="mt-6 rounded-md border border-dashed border-slate-300 p-6 text-slate-500">
          Ingen henvendelser med denne statusen.
        </p>
      )}
      {visibleLeads.length > 0 && (
        <ul className="mt-6 divide-y divide-slate-100 overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
          {visibleLeads.map((lead) => (
            <li key={lead.id}>
              <Link
                to={`/app/leads/${lead.id}`}
                className="flex items-center justify-between gap-4 p-4 hover:bg-slate-50"
              >
                <div className="min-w-0">
                  <p className="font-medium text-slate-900">{lead.name}</p>
                  <p className="mt-1 truncate text-sm text-slate-500">
                    {lead.message}
                  </p>
                  <p className="mt-1 text-xs text-slate-400">
                    {new Intl.DateTimeFormat("nb-NO", {
                      dateStyle: "medium",
                      timeStyle: "short",
                    }).format(new Date(lead.inserted_at))}
                  </p>
                </div>
                <StatusBadge status={lead.status} />
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
