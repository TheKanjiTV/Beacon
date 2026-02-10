# Beacon — Swift Analytics SDK

A lightweight, Swift-first analytics SDK backed by Supabase. Track events from any macOS or iOS app with a simple API, and visualize them in a real-time web dashboard.

## Features

- **Swift-native SDK** — import via SPM, fire-and-forget API that never blocks your app
- **Actor-based concurrency** — fully thread-safe with Swift's structured concurrency
- **Automatic batching** — events are buffered and flushed in batches (configurable threshold and interval)
- **Offline resilience** — unflushed events are persisted to disk and retried on next launch
- **Debug logging** — toggle `os_log` output to see exactly what Beacon is sending
- **Device enrichment** — every event is automatically tagged with OS, app version, device model, and locale
- **Supabase backend** — zero server code to maintain, just a Postgres table with RLS
- **Web dashboard** — Next.js + TailwindCSS with Apple glassmorphism design

## Quick Start

### 1. Set Up Supabase

1. Create a project at [supabase.com](https://supabase.com)
2. Open the SQL Editor and run the contents of [`supabase/schema.sql`](supabase/schema.sql)
3. Copy your **Project URL** and **anon public key** from Settings → API

### 2. Add the SDK to Your App

Add Beacon as a Swift Package dependency:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/William-Laverty/Beacon.git", from: "1.0.0")
]
```

Or in Xcode: File → Add Package Dependencies → paste the repo URL.

### 3. Configure and Track

```swift
import Beacon

// Configure on app launch
Beacon.configure(
    supabaseURL: "https://your-project.supabase.co",
    supabaseKey: "your-anon-key"
)

// Track events
Beacon.track("app_launched")
Beacon.track("button_tapped", properties: ["screen": "settings", "button": "save"])

// Identify users (optional)
Beacon.identify(userId: "user-123", traits: ["plan": "pro"])

// Flush before app terminates (optional — auto-flushes on interval)
Beacon.shutdown()
```

See [`Examples/BasicUsage.swift`](Examples/BasicUsage.swift) for a complete macOS app example.

## SDK API Reference

### `Beacon.configure(supabaseURL:supabaseKey:flushAt:flushInterval:)`

Initialize the SDK. Call once on app launch.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `supabaseURL` | `String` | — | Your Supabase project URL |
| `supabaseKey` | `String` | — | Your Supabase anon public key |
| `flushAt` | `Int` | `20` | Flush when the buffer reaches this many events |
| `flushInterval` | `TimeInterval` | `30` | Flush every N seconds regardless of buffer size |

### `Beacon.track(_:properties:)`

Track a named event with optional properties.

```swift
Beacon.track("purchase_completed", properties: [
    "item_id": "sku-789",
    "price": 9.99,
    "currency": "USD"
])
```

Properties support `String`, `Int`, `Double`, and `Bool` values.

### `Beacon.identify(userId:traits:)`

Associate future events with a user ID. Optionally attach traits as an `identify` event.

```swift
Beacon.identify(userId: "user-123", traits: ["plan": "pro", "signup_source": "organic"])
```

### `Beacon.flush()`

Immediately flush all buffered events to Supabase.

### `Beacon.shutdown()`

Flush remaining events, cancel the flush timer, and tear down the client. Call before app termination.

### `Beacon.enableLogging()`

Turn on debug logging via `os_log`. Shows queued events, flush attempts, errors, and disk persistence activity.

```swift
// Enable during development
Beacon.enableLogging()

// Disable
Beacon.enableLogging(false)
```

## Offline Resilience

If a flush fails (network error, Supabase downtime), events are automatically:
1. Re-queued in memory for the next flush attempt
2. Persisted to `~/Library/Caches/Beacon/pending_events.json`
3. Restored on next app launch and flushed with the first batch

No events are lost between sessions.

## Event Schema

Every event is stored with these fields:

| Column | Type | Description |
|--------|------|-------------|
| `id` | `BIGINT` | Auto-incrementing primary key |
| `event_name` | `TEXT` | Name of the event |
| `user_id` | `TEXT` | Optional user identifier |
| `session_id` | `TEXT` | Auto-generated UUID per app session |
| `properties` | `JSONB` | Custom key-value properties |
| `device_info` | `JSONB` | Auto-collected: `os`, `os_version`, `app_name`, `app_version`, `device_model`, `locale` |
| `timestamp` | `TIMESTAMPTZ` | When the event was created |
| `created_at` | `TIMESTAMPTZ` | When the row was inserted |

## Dashboard

The web dashboard provides a real-time view of your analytics data.

### Setup

```bash
cd dashboard
npm install
```

Create a `.env.local` file:

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

> Use the **service role key** (not the anon key) so the dashboard can read events.

### Development

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

### Pages

- **Overview** (`/`) — Total events, unique users, sessions, and a 7-day event chart
- **Events** (`/events`) — Stream of the 100 most recent events with properties

### Deploy to Vercel

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/William-Laverty/Beacon&root-directory=dashboard&env=NEXT_PUBLIC_SUPABASE_URL,SUPABASE_SERVICE_ROLE_KEY)

Or manually:

```bash
cd dashboard
npx vercel --prod
```

Set the environment variables in your Vercel project settings.

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌───────────┐
│  Your App   │────▶│  Beacon SDK  │────▶│  Supabase │
│             │     │  (EventQueue)│     │  (Postgres)│
└─────────────┘     └──────────────┘     └─────┬─────┘
                                               │
                                         ┌─────▼─────┐
                                         │ Dashboard  │
                                         │ (Next.js)  │
                                         └───────────┘
```

- **Beacon (enum)** — Public static API, fire-and-forget
- **BeaconClient (actor)** — Singleton owning config, queue, user identity, session
- **EventQueue (actor)** — Buffers events, flushes at threshold or interval via PostgREST
- **DiskQueue (actor)** — Persists unflushed events to disk for offline resilience
- **DeviceInfo** — Auto-collects OS, version, device model, locale
- **BeaconEvent** — Codable model with snake_case keys matching Postgres columns

## Requirements

- **SDK**: macOS 13+ / iOS 16+, Swift 5.9+
- **Dashboard**: Node.js 18+

## License

MIT — see [LICENSE](LICENSE).
