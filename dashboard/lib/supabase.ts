import { createClient, SupabaseClient } from '@supabase/supabase-js'

export type Event = {
  id: number
  event_name: string
  user_id: string | null
  session_id: string
  properties: Record<string, unknown> | null
  device_info: Record<string, unknown> | null
  timestamp: string
  created_at: string
}

let _supabase: SupabaseClient | null = null

export function getSupabase(): SupabaseClient | null {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY
  if (!supabaseUrl || !supabaseKey) return null
  if (!_supabase) {
    _supabase = createClient(supabaseUrl, supabaseKey)
  }
  return _supabase
}
