import { Outlet, Link, useNavigate } from "react-router-dom";
import { useAuth } from "../../context/AuthContext";

export default function AppLayout() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  async function handleLogout() {
    await logout();
    navigate("/login", { replace: true });
  }

  return (
    <div className="min-h-screen bg-slate-50">
      <header className="flex items-center justify-between border-b border-slate-200 bg-white px-6 py-3">
        <Link to="/app" className="font-semibold text-slate-900">
          LeadRescue
        </Link>
        <div className="flex items-center gap-4 text-sm text-slate-600">
          <span>
            {user?.first_name} {user?.last_name}
          </span>
          <button onClick={handleLogout} className="underline">
            Logg ut
          </button>
        </div>
      </header>
      <main className="p-6">
        <Outlet />
      </main>
    </div>
  );
}
