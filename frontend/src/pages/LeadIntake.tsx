import { useState, type FormEvent } from "react";
import { Link, useParams } from "react-router-dom";
import { apiRequest, ApiError } from "../lib/api";

const emptyForm = { name: "", email: "", phone: "", message: "" };

export default function LeadIntake() {
  const { companySlug } = useParams();
  const [form, setForm] = useState(emptyForm);
  const [error, setError] = useState<string | null>(null);
  const [fieldErrors, setFieldErrors] = useState<Record<string, string[]>>({});
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  function update(key: keyof typeof form, value: string) {
    setForm((current) => ({ ...current, [key]: value }));
  }

  async function handleSubmit(event: FormEvent) {
    event.preventDefault();
    if (!companySlug) return;

    setError(null);
    setFieldErrors({});
    setSubmitting(true);

    try {
      await apiRequest(
        `/api/public/companies/${encodeURIComponent(companySlug)}/leads`,
        {
          method: "POST",
          authenticated: false,
          body: { lead: form },
        },
      );
      setSubmitted(true);
    } catch (err) {
      if (err instanceof ApiError) {
        setError(
          err.status === 404
            ? "Denne kontaktlenken finnes ikke. Kontroller adressen og prøv igjen."
            : err.message,
        );
        setFieldErrors(err.fields ?? {});
      } else {
        setError("Kunne ikke sende henvendelsen. Prøv igjen om litt.");
      }
    } finally {
      setSubmitting(false);
    }
  }

  if (submitted) {
    return (
      <main className="mx-auto flex min-h-screen max-w-lg flex-col justify-center px-4 py-12 text-center">
        <div className="rounded-xl border border-emerald-200 bg-emerald-50 p-8">
          <h1 className="text-2xl font-semibold text-emerald-950">
            Takk for henvendelsen!
          </h1>
          <p className="mt-3 text-emerald-800">
            Informasjonen er sendt. Bedriften tar kontakt med deg så snart som
            mulig.
          </p>
          <button
            type="button"
            onClick={() => {
              setForm(emptyForm);
              setSubmitted(false);
            }}
            className="mt-6 text-sm font-medium text-emerald-900 underline"
          >
            Send en ny henvendelse
          </button>
        </div>
      </main>
    );
  }

  const inputClass =
    "rounded-md border border-slate-300 px-3 py-2 text-slate-900 focus:border-slate-500 focus:outline-none";

  return (
    <main className="mx-auto flex min-h-screen max-w-lg flex-col justify-center px-4 py-12">
      <div className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm sm:p-8">
        <p className="text-sm font-medium text-slate-500">Kontakt oss</p>
        <h1 className="mt-1 text-2xl font-semibold text-slate-900">
          Hva kan vi hjelpe deg med?
        </h1>
        <p className="mt-2 text-sm text-slate-600">
          Beskriv behovet ditt, så tar vi kontakt så snart som mulig.
        </p>

        <form
          onSubmit={handleSubmit}
          className="mt-6 flex flex-col gap-4"
          noValidate
        >
          <Field label="Navn" error={fieldErrors.name?.[0]}>
            <input
              required
              autoComplete="name"
              value={form.name}
              onChange={(e) => update("name", e.target.value)}
              className={inputClass}
            />
          </Field>
          <Field label="E-post" error={fieldErrors.email?.[0]}>
            <input
              required
              type="email"
              autoComplete="email"
              value={form.email}
              onChange={(e) => update("email", e.target.value)}
              className={inputClass}
            />
          </Field>
          <Field label="Telefon (valgfritt)" error={fieldErrors.phone?.[0]}>
            <input
              type="tel"
              autoComplete="tel"
              value={form.phone}
              onChange={(e) => update("phone", e.target.value)}
              className={inputClass}
            />
          </Field>
          <Field label="Hva gjelder det?" error={fieldErrors.message?.[0]}>
            <textarea
              required
              rows={6}
              value={form.message}
              onChange={(e) => update("message", e.target.value)}
              className={`${inputClass} resize-y`}
            />
          </Field>

          {error && (
            <p role="alert" className="text-sm text-red-600">
              {error}
            </p>
          )}

          <button
            type="submit"
            disabled={submitting}
            className="rounded-md bg-slate-900 px-4 py-3 font-medium text-white disabled:opacity-50"
          >
            {submitting ? "Sender..." : "Send henvendelse"}
          </button>
        </form>
      </div>
      <p className="mt-4 text-center text-xs text-slate-500">
        Levert av{" "}
        <Link to="/" className="font-medium underline">
          LeadRescue
        </Link>
      </p>
    </main>
  );
}

function Field({
  label,
  error,
  children,
}: {
  label: string;
  error?: string;
  children: React.ReactNode;
}) {
  return (
    <label className="flex flex-col gap-1 text-sm font-medium text-slate-700">
      {label}
      {children}
      {error && <span className="font-normal text-red-600">{error}</span>}
    </label>
  );
}
