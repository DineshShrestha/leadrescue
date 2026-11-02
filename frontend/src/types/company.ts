export type Company = {
  id: string;
  name: string;
  slug: string;
  organization_number: string | null;
  email: string | null;
  phone: string | null;
  website: string | null;
  address: string | null;
  postcode: string | null;
  city: string | null;
  timezone: string;
  subscription_status: string;
  subscription_plan: string;
  trial_ends_at: string | null;
};
