import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import { apiRequest, getToken, setToken } from "../lib/api";

export type Role = "super_admin" | "company_admin" | "company_user";

export type User = {
  id: string;
  company_id: string | null;
  first_name: string;
  last_name: string;
  email: string;
  role: Role;
  active: boolean;
  confirmed_at: string | null;
};

type AuthContextValue = {
  user: User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  refresh: () => Promise<void>;
};

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  async function refresh() {
    if (!getToken()) {
      setUser(null);
      setLoading(false);
      return;
    }

    try {
      const { user } = await apiRequest<{ user: User }>("/api/account");
      setUser(user);
    } catch {
      setToken(null);
      setUser(null);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    refresh();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function login(email: string, password: string) {
    const data = await apiRequest<{ token: string; user: User }>("/api/auth/login", {
      method: "POST",
      body: { email, password },
      authenticated: false,
    });
    setToken(data.token);
    setUser(data.user);
  }

  async function logout() {
    try {
      await apiRequest("/api/auth/logout", { method: "DELETE" });
    } finally {
      setToken(null);
      setUser(null);
    }
  }

  return (
    <AuthContext.Provider value={{ user, loading, login, logout, refresh }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within an AuthProvider");
  return ctx;
}
