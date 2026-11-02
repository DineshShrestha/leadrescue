import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { apiRequest, ApiError } from "../../lib/api";
import type { Lead } from "../../types/lead";

export default function LeadDetail() {
  const { leadId } = useParams();
  const [lead, setLead] = useState<Lead | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [savingStatus, setSavingStatus] = useState(false);
  const [statusError, setStatusError] = useState<string | null>(null);

  useEffect(() => {
    if (!leadId) return;
    apiRequest<{ data: Lead }>(`/api/leads/${encodeURIComponent(leadId)}`)
      .then(({ data }) => setLead(data))
      .catch((err) =>
        setError(
          err instanceof ApiError && err.status === 404
            ? "Henvendelsen finnes ikke."
            : "Kunne ikke hente henvendelsen.",
        ),
      );
  }, [leadId]);

  if (error)
    return (
      <div>
        <Link to="/app" className="text-sm underline">
          ← Tilbake
        </Link>
        <p role="alert" className="mt-6 text-red-600">
          {error}
        </p>
      </div>
    );
  if (!lead) return <p className="text-slate-500">Laster henvendelse...</p>;

  async function updateStatus(status: Lead["status"]) {
    if (!lead || status === lead.status) return;
    setSavingStatus(true);
    setStatusError(null);
    try {
      const { data } = await apiRequest<{ data: Lead }>(
        `/api/leads/${encodeURIComponent(lead.id)}`,
        { method: "PUT", body: { lead: { status } } },
      );
      setLead(data);
    } catch {
      setStatusError("Kunne ikke oppdatere status.");
    } finally {
      setSavingStatus(false);
    }
  }

  return (
    <div className="mx-auto max-w-3xl">
      <Link to="/app" className="text-sm text-slate-600 underline">
        ← Alle henvendelser
      </Link>
      <div className="mt-5 rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div>
            <h1 className="text-2xl font-semibold text-slate-900">
              {lead.name}
            </h1>
            <p className="mt-1 text-sm text-slate-500">Kundehenvendelse</p>
          </div>
          <div className="flex flex-col items-end gap-1">
            <label
              className="text-xs font-medium text-slate-500"
              htmlFor="lead-status"
            >
              Status
            </label>
            <select
              id="lead-status"
              value={lead.status}
              disabled={savingStatus}
              onChange={(event) =>
                updateStatus(event.target.value as Lead["status"])
              }
              className="rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 disabled:opacity-50"
            >
              {Object.entries(statusLabels).map(([value, label]) => (
                <option key={value} value={value}>
                  {label}
                </option>
              ))}
            </select>
            {statusError && (
              <span role="alert" className="text-xs text-red-600">
                {statusError}
              </span>
            )}
          </div>
        </div>
        <dl className="mt-6 grid gap-4 border-y border-slate-100 py-5 sm:grid-cols-2">
          <Contact
            label="E-post"
            value={lead.email}
            href={`mailto:${lead.email}`}
          />
          <Contact
            label="Telefon"
            value={lead.phone || "Ikke oppgitt"}
            href={lead.phone ? `tel:${lead.phone}` : undefined}
          />
        </dl>
        <div className="mt-6">
          <h2 className="text-sm font-medium text-slate-500">Melding</h2>
          <p className="mt-2 whitespace-pre-wrap text-slate-800">
            {lead.message}
          </p>
        </div>
      </div>
    </div>
  );
}

function Contact({
  label,
  value,
  href,
}: {
  label: string;
  value: string;
  href?: string;
}) {
  return (
    <div>
      <dt className="text-sm text-slate-500">{label}</dt>
      <dd className="mt-1 font-medium text-slate-900">
        {href ? (
          <a href={href} className="underline">
            {value}
          </a>
        ) : (
          value
        )}
      </dd>
    </div>
  );
}

export function StatusBadge({ status }: { status: Lead["status"] }) {
  return (
    <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-700">
      {statusLabels[status]}
    </span>
  );
}

const statusLabels: Record<Lead["status"], string> = {
  new: "Ny",
  contacted: "Kontaktet",
  qualified: "Kvalifisert",
  won: "Vunnet",
  lost: "Tapt",
};
