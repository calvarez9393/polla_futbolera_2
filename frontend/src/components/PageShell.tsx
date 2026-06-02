import { Outlet } from "react-router-dom";
import { Navbar } from "./Navbar";

export function PageShell() {
  return (
    <div className="page-wrap">
      <div className="bg-beams" aria-hidden />
      <Navbar />
      <main className="content">
        <Outlet />
      </main>
    </div>
  );
}
