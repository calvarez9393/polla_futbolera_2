import type { PropsWithChildren } from "react";
import { Navigate } from "react-router-dom";
import { getUser } from "../lib/auth";

export function AdminRoute({ children }: PropsWithChildren) {
  const user = getUser();
  if (!user || user.role !== "ADMIN") return <Navigate to="/predictions" replace />;
  return children;
}
