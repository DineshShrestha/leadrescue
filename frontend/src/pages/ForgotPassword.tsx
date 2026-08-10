import { useState, type FormEvent } from "react";
import { Link } from "react-router-dom";
import { apiRequest } from "../lib/api";

export default function ForgotPassword() {
  const [email, setEmail] = useState("");
  const [sent, setSent] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    try {
      await apiRequest("/api/auth/reset-password", { method: "POST", body: { email }, authenticated: false });
    } finally {
      setSubmitting(false);
      setSent(true);
    }
  }

  return (
    <div className="mx-auto flex min-h-screen max-w-sm flex-col justify-center px-4">
      <h1 className="mb-6 text-2xl font-semibold text-slate-900">Glemt passord</h1>

      {sent ? (
        <p className="text-sm text-slate-700">
          Hvis e-posten finnes hos oss, sender vi deg instruksjoner for å tilbakestille passordet.
        </p>
      ) : (
        <form onSubmit={handleSubmit} className="flex flex-col gap-4" noValidate>
          <label className="flex flex-col gap-1 text-sm font-medium text-slate-700">
            E-post
            <input
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="rounded-md border border-slate-300 px-3 py-2 text-slate-900 focus:border-slate-500 focus:outline-none"
            />
          </label>
          <button
            type="submit"
            disabled={submitting}
            className="rounded-md bg-slate-900 px-4 py-2 font-medium text-white disabled:opacity-50"
          >
            {submitting ? "Sender..." : "Send instruksjoner"}
          </button>
        </form>
      )}

      <Link to="/login" className="mt-4 text-sm text-slate-600 underline">
        Tilbake til innlogging
      </Link>
    </div>
  );
}
