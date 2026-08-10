import { useState, type FormEvent } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { ApiError } from "../lib/api";

export default function Login() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      await login(email, password);
      const to = (location.state as { from?: string })?.from ?? "/app";
      navigate(to, { replace: true });
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Kunne ikke logge inn.");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="mx-auto flex min-h-screen max-w-sm flex-col justify-center px-4">
      <h1 className="mb-6 text-2xl font-semibold text-slate-900">Logg inn på LeadRescue</h1>
      <form onSubmit={handleSubmit} className="flex flex-col gap-4" noValidate>
        <label className="flex flex-col gap-1 text-sm font-medium text-slate-700">
          E-post
          <input
            type="email"
            required
            autoComplete="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="rounded-md border border-slate-300 px-3 py-2 text-slate-900 focus:border-slate-500 focus:outline-none"
          />
        </label>
        <label className="flex flex-col gap-1 text-sm font-medium text-slate-700">
          Passord
          <input
            type="password"
            required
            autoComplete="current-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
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
          {submitting ? "Logger inn..." : "Logg inn"}
        </button>
      </form>

      <div className="mt-4 flex justify-between text-sm text-slate-600">
        <Link to="/forgot-password" className="underline">
          Glemt passord?
        </Link>
        <Link to="/register" className="underline">
          Registrer firma
        </Link>
      </div>
    </div>
  );
}
