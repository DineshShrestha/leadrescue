import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { apiRequest, ApiError } from "../../lib/api";
import type { Lead } from "../../types/lead";

export default function LeadDetail() {
  const { leadId } = useParams();
  const [lead, setLead] = useState<Lead | null>(null);
  const [error, setError] = useState<string | null>(null);

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
            <p className="mt-1 text-sm text-slate-500">Ny henvendelse</p>
          </div>
          <StatusBadge status={lead.status} />
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
  const labels: Record<Lead["status"], string> = {
    new: "Ny",
    contacted: "Kontaktet",
    qualified: "Kvalifisert",
    won: "Vunnet",
    lost: "Tapt",
  };
  return (
    <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-700">
      {labels[status]}
    </span>
  );
}
