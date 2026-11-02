export type Lead = {
  id: string;
  company_id: string;
  name: string;
  email: string;
  phone: string | null;
  message: string;
  status: "new" | "contacted" | "qualified" | "won" | "lost";
  source: string;
};
