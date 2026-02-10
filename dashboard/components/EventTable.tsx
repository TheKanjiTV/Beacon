import { format } from "date-fns"
import type { Event } from "@/lib/supabase"

export default function EventTable({ events }: { events: Event[] }) {
  return (
    <div className="glass-card overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full text-left text-sm">
          <thead>
            <tr className="border-b border-apple-border">
              <th className="px-6 py-3 text-xs font-medium text-apple-secondary uppercase tracking-wider">
                Event Name
              </th>
              <th className="px-6 py-3 text-xs font-medium text-apple-secondary uppercase tracking-wider">
                User ID
              </th>
              <th className="px-6 py-3 text-xs font-medium text-apple-secondary uppercase tracking-wider">
                Session ID
              </th>
              <th className="px-6 py-3 text-xs font-medium text-apple-secondary uppercase tracking-wider">
                Timestamp
              </th>
              <th className="px-6 py-3 text-xs font-medium text-apple-secondary uppercase tracking-wider">
                Properties
              </th>
            </tr>
          </thead>
          <tbody>
            {events.map((event, i) => (
              <tr
                key={event.id}
                className={`border-b border-apple-border last:border-0 ${
                  i % 2 === 1 ? "bg-black/[0.015]" : ""
                }`}
              >
                <td className="px-6 py-3 font-medium text-apple-text whitespace-nowrap">
                  {event.event_name}
                </td>
                <td className="px-6 py-3 text-apple-secondary font-mono text-xs whitespace-nowrap">
                  {event.user_id ? event.user_id.slice(0, 12) + "..." : "--"}
                </td>
                <td className="px-6 py-3 text-apple-secondary font-mono text-xs whitespace-nowrap">
                  {event.session_id.slice(0, 12)}...
                </td>
                <td className="px-6 py-3 text-apple-secondary whitespace-nowrap">
                  {format(new Date(event.timestamp), "MMM d, h:mm a")}
                </td>
                <td className="px-6 py-3 text-apple-secondary font-mono text-xs max-w-[200px] truncate">
                  {event.properties
                    ? JSON.stringify(event.properties).slice(0, 60)
                    : "--"}
                </td>
              </tr>
            ))}
            {events.length === 0 && (
              <tr>
                <td
                  colSpan={5}
                  className="px-6 py-12 text-center text-apple-secondary"
                >
                  No events recorded yet.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  )
}
