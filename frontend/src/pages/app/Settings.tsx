import { useEffect, useMemo, useState, type FormEvent } from "react";
import { useAuth } from "../../hooks/useAuth";
import { apiRequest, ApiError } from "../../lib/api";
import type { Company } from "../../types/company";

const editableFields = [
  "name",
  "organization_number",
  "email",
  "phone",
  "website",
  "address",
  "postcode",
  "city",
] as const;

export default function Settings() {
  const { user } = useAuth();
  const [company, setCompany] = useState<Company | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    if (!user?.company_id) {
      setLoading(false);
      return;
    }
    apiRequest<{ data: Company }>(`/api/companies/${user.company_id}`)
      .then(({ data }) => setCompany(data))
      .catch(() => setError("Kunne ikke hente firmainnstillingene."))
      .finally(() => setLoading(false));
  }, [user?.company_id]);

  const intakeUrl = useMemo(
    () => (company ? `${window.location.origin}/r/${company.slug}` : ""),
    [company],
  );

  function update(field: (typeof editableFields)[number], value: string) {
    setCompany((current) =>
      current ? { ...current, [field]: value } : current,
    );
  }

  async function save(event: FormEvent) {
    event.preventDefault();
    if (!company) return;
    setSaving(true);
    setMessage(null);
    setError(null);
    try {
      const body = Object.fromEntries(
        editableFields.map((field) => [field, company[field] || null]),
      );
      const { data } = await apiRequest<{ data: Company }>(
        `/api/companies/${company.id}`,
        { method: "PUT", body: { company: body } },
      );
      setCompany(data);
      setMessage("Firmainnstillingene er lagret.");
    } catch (err) {
      setError(
        err instanceof ApiError
          ? err.message
          : "Kunne ikke lagre firmainnstillingene.",
      );
    } finally {
      setSaving(false);
    }
  }

  async function copyLink() {
    await navigator.clipboard.writeText(intakeUrl);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 2000);
  }

  if (loading) return <p className="text-slate-500">Laster innstillinger...</p>;
  if (!company)
    return (
      <p role="alert" className="text-red-600">
        {error || "Ingen bedrift er knyttet til kontoen."}
      </p>
    );
  const canEdit =
    user?.role === "company_admin" || user?.role === "super_admin";

  return (
    <div className="mx-auto max-w-3xl">
      <h1 className="text-xl font-semibold text-slate-900">Innstillinger</h1>
      <p className="mt-2 text-slate-600">
        Administrer firmaprofilen og kundelenken.
      </p>

      <section className="mt-6 rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <h2 className="font-semibold text-slate-900">Kundelenke</h2>
        <p className="mt-1 text-sm text-slate-600">
          Del denne lenken med kunder eller legg den på nettsiden din.
        </p>
        <div className="mt-4 flex flex-col gap-2 sm:flex-row">
          <input
            readOnly
            value={intakeUrl}
            className="min-w-0 flex-1 rounded-md border border-slate-300 bg-slate-50 px-3 py-2 text-sm"
          />
          <button
            type="button"
            onClick={copyLink}
            className="rounded-md bg-slate-900 px-4 py-2 text-sm font-medium text-white"
          >
            {copied ? "Kopiert" : "Kopier lenke"}
          </button>
          <a
            href={intakeUrl}
            target="_blank"
            rel="noreferrer"
            className="rounded-md border border-slate-300 px-4 py-2 text-center text-sm font-medium text-slate-700"
          >
            Åpne
          </a>
        </div>
      </section>

      <form
        onSubmit={save}
        className="mt-6 rounded-xl border border-slate-200 bg-white p-6 shadow-sm"
      >
        <h2 className="font-semibold text-slate-900">Firmaprofil</h2>
        <div className="mt-4 grid gap-4 sm:grid-cols-2">
          <Input
            label="Firmanavn"
            value={company.name}
            onChange={(value) => update("name", value)}
            required
            disabled={!canEdit}
          />
          <Input
            label="Organisasjonsnummer"
            value={company.organization_number || ""}
            onChange={(value) => update("organization_number", value)}
            disabled={!canEdit}
          />
          <Input
            label="E-post"
            type="email"
            value={company.email || ""}
            onChange={(value) => update("email", value)}
            disabled={!canEdit}
          />
          <Input
            label="Telefon"
            type="tel"
            value={company.phone || ""}
            onChange={(value) => update("phone", value)}
            disabled={!canEdit}
          />
          <Input
            label="Nettside"
            type="url"
            value={company.website || ""}
            onChange={(value) => update("website", value)}
            disabled={!canEdit}
          />
          <Input
            label="Adresse"
            value={company.address || ""}
            onChange={(value) => update("address", value)}
            disabled={!canEdit}
          />
          <Input
            label="Postnummer"
            value={company.postcode || ""}
            onChange={(value) => update("postcode", value)}
            disabled={!canEdit}
          />
          <Input
            label="Sted"
            value={company.city || ""}
            onChange={(value) => update("city", value)}
            disabled={!canEdit}
          />
        </div>
        {message && (
          <p role="status" className="mt-4 text-sm text-emerald-700">
            {message}
          </p>
        )}
        {error && (
          <p role="alert" className="mt-4 text-sm text-red-600">
            {error}
          </p>
        )}
        {canEdit && (
          <button
            type="submit"
            disabled={saving}
            className="mt-5 rounded-md bg-slate-900 px-4 py-2 font-medium text-white disabled:opacity-50"
          >
            {saving ? "Lagrer..." : "Lagre endringer"}
          </button>
        )}
      </form>
    </div>
  );
}

function Input({
  label,
  value,
  onChange,
  type = "text",
  required = false,
  disabled = false,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
  type?: string;
  required?: boolean;
  disabled?: boolean;
}) {
  return (
    <label className="flex flex-col gap-1 text-sm font-medium text-slate-700">
      {label}
      <input
        type={type}
        required={required}
        disabled={disabled}
        value={value}
        onChange={(event) => onChange(event.target.value)}
        className="rounded-md border border-slate-300 px-3 py-2 text-slate-900 disabled:bg-slate-100 disabled:text-slate-500"
      />
    </label>
  );
}
