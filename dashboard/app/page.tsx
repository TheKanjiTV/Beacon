import MetricCard from "@/components/MetricCard"
import EventChart from "@/components/EventChart"
import { getSupabase } from "@/lib/supabase"
import { format, subDays } from "date-fns"

export const revalidate = 60

async function getMetrics() {
  const supabase = getSupabase()
  if (!supabase) return null

  const [totalRes, usersRes, sessionsRes] = await Promise.all([
    supabase.from("events").select("*", { count: "exact", head: true }),
    supabase.from("events").select("user_id").not("user_id", "is", null),
    supabase.from("events").select("session_id"),
  ])

  const uniqueUsers = new Set(usersRes.data?.map((r) => r.user_id)).size
  const uniqueSessions = new Set(sessionsRes.data?.map((r) => r.session_id)).size

  const sevenDaysAgo = subDays(new Date(), 7).toISOString()
  const { data: recentEvents } = await supabase
    .from("events")
    .select("timestamp")
    .gte("timestamp", sevenDaysAgo)
    .order("timestamp", { ascending: true })

  const dailyCounts: Record<string, number> = {}
  for (let i = 6; i >= 0; i--) {
    const day = format(subDays(new Date(), i), "MMM d")
    dailyCounts[day] = 0
  }
  recentEvents?.forEach((e) => {
    const day = format(new Date(e.timestamp), "MMM d")
    if (day in dailyCounts) dailyCounts[day]++
  })

  const chartData = Object.entries(dailyCounts).map(([date, count]) => ({
    date,
    count,
  }))

  return {
    totalEvents: totalRes.count ?? 0,
    uniqueUsers,
    uniqueSessions,
    chartData,
  }
}

export default async function OverviewPage() {
  const metrics = await getMetrics()

  if (!metrics) {
    return (
      <div className="max-w-2xl mx-auto mt-24 text-center">
        <h1 className="text-2xl font-semibold text-apple-text mb-3">
          Setup Required
        </h1>
        <p className="text-apple-secondary leading-relaxed">
          Set <code className="bg-black/5 px-1.5 py-0.5 rounded text-sm">NEXT_PUBLIC_SUPABASE_URL</code> and{" "}
          <code className="bg-black/5 px-1.5 py-0.5 rounded text-sm">SUPABASE_SERVICE_ROLE_KEY</code> in your{" "}
          <code className="bg-black/5 px-1.5 py-0.5 rounded text-sm">.env.local</code> file to connect the dashboard.
        </p>
      </div>
    )
  }

  return (
    <div>
      <h1 className="text-2xl font-semibold tracking-tight text-apple-text mb-6">
        Overview
      </h1>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-5 mb-6">
        <MetricCard label="Total Events" value={metrics.totalEvents} />
        <MetricCard label="Unique Users" value={metrics.uniqueUsers} />
        <MetricCard label="Unique Sessions" value={metrics.uniqueSessions} />
      </div>
      <EventChart data={metrics.chartData} />
    </div>
  )
}
