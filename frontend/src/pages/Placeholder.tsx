export default function Placeholder({ title }: { title: string }) {
  return (
    <div className="mx-auto max-w-2xl px-4 py-16">
      <h1 className="text-2xl font-semibold text-slate-900">{title}</h1>
      <p className="mt-2 text-slate-600">Innhold kommer.</p>
    </div>
  );
}
