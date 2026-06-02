import { Navigate, Route, Routes } from "react-router-dom";
import { PageShell } from "./components/PageShell";
import { ProtectedRoute } from "./components/ProtectedRoute";
import { AdminRoute } from "./components/AdminRoute";
import { HomePage } from "./pages/HomePage";
import { LoginPage } from "./pages/LoginPage";
import { StandingsPage } from "./pages/StandingsPage";
import { PredictionsPage } from "./pages/PredictionsPage";
import { QualifiersPage } from "./pages/QualifiersPage";
import { BracketPage } from "./pages/BracketPage";
import { R16BracketPage } from "./pages/R16BracketPage";
import { ExtrasPage } from "./pages/ExtrasPage";
import { LeaderboardPage } from "./pages/LeaderboardPage";
import { AdminPage } from "./pages/AdminPage";
import { AdminCalendarPage } from "./pages/AdminCalendarPage";
import { AdminUsersPage } from "./pages/AdminUsersPage";
import { AdminOfficialPage } from "./pages/AdminOfficialPage";
import { MyPointsPage } from "./pages/MyPointsPage";

function App() {
  return (
    <Routes>
      <Route element={<PageShell />}>
        <Route path="/" element={<HomePage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<Navigate to="/login" replace />} />
        <Route path="/matches" element={<Navigate to="/predictions" replace />} />
        <Route path="/predictions" element={<PredictionsPage />} />
        <Route path="/standings" element={<StandingsPage />} />
        <Route path="/leaderboard" element={<LeaderboardPage />} />
        <Route element={<ProtectedRoute />}>
          <Route path="/my-points" element={<MyPointsPage />} />
          <Route path="/predictions/qualifiers" element={<QualifiersPage />} />
          <Route path="/predictions/r16" element={<R16BracketPage />} />
          <Route path="/predictions/bracket" element={<BracketPage />} />
          <Route path="/predictions/extras" element={<ExtrasPage />} />
          <Route
            path="/admin"
            element={
              <AdminRoute>
                <AdminPage />
              </AdminRoute>
            }
          />
          <Route
            path="/admin/calendar"
            element={
              <AdminRoute>
                <AdminCalendarPage />
              </AdminRoute>
            }
          />
          <Route
            path="/admin/users"
            element={
              <AdminRoute>
                <AdminUsersPage />
              </AdminRoute>
            }
          />
          <Route
            path="/admin/official"
            element={
              <AdminRoute>
                <AdminOfficialPage />
              </AdminRoute>
            }
          />
        </Route>
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default App;
