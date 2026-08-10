import { useAuth } from "../../context/AuthContext";

export default function Dashboard() {
  const { user } = useAuth();

  return (
    <div>
      <h1 className="text-xl font-semibold text-slate-900">Oversikt</h1>
      <p className="mt-2 text-slate-600">
        Innlogget som {user?.email} ({user?.role}).
      </p>
      <p className="mt-4 rounded-md border border-dashed border-slate-300 p-6 text-slate-500">
        Ingen henvendelser ennå. Del LeadRescue-lenken din med en kunde, eller send en test-henvendelse.
      </p>
    </div>
  );
}
