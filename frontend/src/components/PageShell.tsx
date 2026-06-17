import { Outlet } from "react-router-dom";
import { Navbar } from "./Navbar";
import { ExtrasReminderModal } from "./ExtrasReminderModal";

export function PageShell() {
  return (
    <div className="page-wrap">
      <div className="bg-beams" aria-hidden />
      <Navbar />
      <main className="content">
        <Outlet />
      </main>
      <ExtrasReminderModal />
    </div>
  );
}
