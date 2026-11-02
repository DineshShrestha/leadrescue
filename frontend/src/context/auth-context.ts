import { createContext } from "react";

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

export type AuthContextValue = {
  user: User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  refresh: () => Promise<void>;
};

export const AuthContext = createContext<AuthContextValue | null>(null);
