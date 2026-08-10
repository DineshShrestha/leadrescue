import { BrowserRouter, Routes, Route } from "react-router-dom";
import { AuthProvider } from "./context/AuthContext";
import Home from "./pages/Home";
import Login from "./pages/Login";
import Register from "./pages/Register";
import ForgotPassword from "./pages/ForgotPassword";
import Placeholder from "./pages/Placeholder";
import RequireAuth from "./pages/app/RequireAuth";
import AppLayout from "./pages/app/AppLayout";
import Dashboard from "./pages/app/Dashboard";

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/pricing" element={<Placeholder title="Priser" />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route path="/forgot-password" element={<ForgotPassword />} />
          <Route path="/privacy" element={<Placeholder title="Personvern" />} />
          <Route path="/terms" element={<Placeholder title="Vilkår" />} />
          <Route path="/r/:companySlug" element={<Placeholder title="Kontaktskjema" />} />

          <Route
            path="/app"
            element={
              <RequireAuth>
                <AppLayout />
              </RequireAuth>
            }
          >
            <Route index element={<Dashboard />} />
          </Route>

          <Route path="*" element={<Placeholder title="Fant ikke siden" />} />
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  );
}
