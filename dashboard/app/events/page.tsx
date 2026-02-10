import EventTable from "@/components/EventTable"
import { getSupabase, type Event } from "@/lib/supabase"

export const revalidate = 60

async function getEvents(): Promise<Event[] | null> {
  const supabase = getSupabase()
  if (!supabase) return null

  const { data } = await supabase
    .from("events")
    .select("*")
    .order("timestamp", { ascending: false })
    .limit(100)

  return (data as Event[]) ?? []
}

export default async function EventsPage() {
  const events = await getEvents()

  if (!events) {
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
        Events
      </h1>
      <EventTable events={events} />
    </div>
  )
}
