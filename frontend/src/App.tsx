import { BrowserRouter, Routes, Route } from "react-router-dom";
import { AuthProvider } from "./context/AuthContext";
import Home from "./pages/Home";
import Login from "./pages/Login";
import Register from "./pages/Register";
import Placeholder from "./pages/Placeholder";
import RequireAuth from "./pages/app/RequireAuth";
import AppLayout from "./pages/app/AppLayout";
import Dashboard from "./pages/app/Dashboard";
import LeadIntake from "./pages/LeadIntake";
import LeadDetail from "./pages/app/LeadDetail";
import Settings from "./pages/app/Settings";

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route path="/privacy" element={<Placeholder title="Personvern" />} />
          <Route path="/terms" element={<Placeholder title="Vilkår" />} />
          <Route path="/r/:companySlug" element={<LeadIntake />} />

          <Route
            path="/app"
            element={
              <RequireAuth>
                <AppLayout />
              </RequireAuth>
            }
          >
            <Route index element={<Dashboard />} />
            <Route path="leads/:leadId" element={<LeadDetail />} />
            <Route path="settings" element={<Settings />} />
          </Route>

          <Route path="*" element={<Placeholder title="Fant ikke siden" />} />
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  );
}
