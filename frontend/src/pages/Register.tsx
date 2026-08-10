import { useState, type FormEvent } from "react";
import { Link, useNavigate } from "react-router-dom";
import { apiRequest, ApiError } from "../lib/api";

export default function Register() {
  const navigate = useNavigate();
  const [form, setForm] = useState({
    name: "",
    admin_first_name: "",
    admin_last_name: "",
    admin_email: "",
    password: "",
  });
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  function update<K extends keyof typeof form>(key: K, value: string) {
    setForm((f) => ({ ...f, [key]: value }));
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      await apiRequest("/api/auth/register", { method: "POST", body: form, authenticated: false });
      navigate("/login", { state: { registered: true } });
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Kunne ikke registrere firma.");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="mx-auto flex min-h-screen max-w-sm flex-col justify-center px-4 py-10">
      <h1 className="mb-2 text-2xl font-semibold text-slate-900">Start gratis prøveperiode</h1>
      <p className="mb-6 text-sm text-slate-600">14 dager, ingen bindingstid.</p>
      <form onSubmit={handleSubmit} className="flex flex-col gap-4" noValidate>
        <label className="flex flex-col gap-1 text-sm font-medium text-slate-700">
          Firmanavn
          <input
            required
            value={form.name}
            onChange={(e) => update("name", e.target.value)}
            className="rounded-md border border-slate-300 px-3 py-2 text-slate-900 focus:border-slate-500 focus:outline-none"
          />
        </label>
        <div className="flex gap-3">
          <label className="flex flex-1 flex-col gap-1 text-sm font-medium text-slate-700">
            Fornavn
            <input
              required
              value={form.admin_first_name}
              onChange={(e) => update("admin_first_name", e.target.value)}
              className="rounded-md border border-slate-300 px-3 py-2 text-slate-900 focus:border-slate-500 focus:outline-none"
            />
          </label>
          <label className="flex flex-1 flex-col gap-1 text-sm font-medium text-slate-700">
            Etternavn
            <input
              required
              value={form.admin_last_name}
              onChange={(e) => update("admin_last_name", e.target.value)}
              className="rounded-md border border-slate-300 px-3 py-2 text-slate-900 focus:border-slate-500 focus:outline-none"
            />
          </label>
        </div>
        <label className="flex flex-col gap-1 text-sm font-medium text-slate-700">
          E-post
          <input
            type="email"
            required
            value={form.admin_email}
            onChange={(e) => update("admin_email", e.target.value)}
            className="rounded-md border border-slate-300 px-3 py-2 text-slate-900 focus:border-slate-500 focus:outline-none"
          />
        </label>
        <label className="flex flex-col gap-1 text-sm font-medium text-slate-700">
          Passord
          <input
            type="password"
            required
            minLength={12}
            autoComplete="new-password"
            value={form.password}
            onChange={(e) => update("password", e.target.value)}
            className="rounded-md border border-slate-300 px-3 py-2 text-slate-900 focus:border-slate-500 focus:outline-none"
          />
        </label>

        {error && (
          <p role="alert" className="text-sm text-red-600">
            {error}
          </p>
        )}

        <button
          type="submit"
          disabled={submitting}
          className="rounded-md bg-slate-900 px-4 py-2 font-medium text-white disabled:opacity-50"
        >
          {submitting ? "Registrerer..." : "Start gratis prøveperiode"}
        </button>
      </form>

      <p className="mt-4 text-sm text-slate-600">
        Har du allerede en konto?{" "}
        <Link to="/login" className="underline">
          Logg inn
        </Link>
      </p>
    </div>
  );
}
