import { Outlet, useLocation } from "react-router-dom";
import { Navbar } from "./Navbar";
import { ExtrasReminderModal } from "./ExtrasReminderModal";

// Rutas que usan el ancho completo (cuadros eliminatorios anchos, no la columna estrecha).
const FULL_WIDTH_ROUTES = ["/admin/brackets"];

export function PageShell() {
  const { pathname } = useLocation();
  const fullWidth = FULL_WIDTH_ROUTES.some((p) => pathname.startsWith(p));
  return (
    <div className="page-wrap">
      <div className="bg-beams" aria-hidden />
      <Navbar />
      <main className={`content${fullWidth ? " content--full" : ""}`}>
        <Outlet />
      </main>
      <ExtrasReminderModal />
    </div>
  );
}
