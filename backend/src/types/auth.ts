export interface AuthUser {
  id: number;
  email: string;
  role: "USER" | "ADMIN";
}
