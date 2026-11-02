import { Outlet, Link, useNavigate } from "react-router-dom";
import { useAuth } from "../../hooks/useAuth";

export default function AppLayout() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  async function handleLogout() {
    await logout();
    navigate("/login", { replace: true });
  }

  return (
    <div className="min-h-screen bg-slate-50">
      <header className="flex flex-wrap items-center justify-between gap-4 border-b border-slate-200 bg-white px-4 py-3 sm:px-6">
        <div className="flex items-center gap-6">
          <Link to="/app" className="font-semibold text-slate-900">
            LeadRescue
          </Link>
          <nav className="flex gap-4 text-sm text-slate-600">
            <Link to="/app" className="hover:text-slate-900">
              Henvendelser
            </Link>
            <Link to="/app/settings" className="hover:text-slate-900">
              Innstillinger
            </Link>
          </nav>
        </div>
        <div className="flex items-center gap-4 text-sm text-slate-600">
          <span>
            {user?.first_name} {user?.last_name}
          </span>
          <button onClick={handleLogout} className="underline">
            Logg ut
          </button>
        </div>
      </header>
      <main className="p-4 sm:p-6">
        <Outlet />
      </main>
    </div>
  );
}
