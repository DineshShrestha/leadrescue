import { Link } from "react-router-dom";

export default function Home() {
  return (
    <div className="mx-auto flex min-h-screen max-w-3xl flex-col items-center justify-center px-4 text-center">
      <h1 className="text-4xl font-semibold text-slate-900">
        Fang opp kunder før de ringer neste rørlegger.
      </h1>
      <p className="mt-4 max-w-xl text-slate-600">
        LeadRescue samler inn informasjon fra kunder, vurderer hvor mye det haster og sender deg en
        ferdig strukturert henvendelse.
      </p>
      <div className="mt-8 flex gap-4">
        <Link to="/register" className="rounded-md bg-slate-900 px-5 py-3 font-medium text-white">
          Start gratis prøveperiode
        </Link>
        <Link to="/pricing" className="rounded-md border border-slate-300 px-5 py-3 font-medium text-slate-900">
          Se priser
        </Link>
      </div>
    </div>
  );
}
