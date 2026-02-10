export default function MetricCard({
  label,
  value,
}: {
  label: string
  value: string | number
}) {
  return (
    <div className="glass-card px-6 py-5">
      <p className="text-sm text-apple-secondary font-medium">{label}</p>
      <p className="text-3xl font-semibold tracking-tight text-apple-text mt-1">
        {typeof value === "number" ? value.toLocaleString() : value}
      </p>
    </div>
  )
}
