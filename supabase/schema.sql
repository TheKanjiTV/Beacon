CREATE TABLE events (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_name TEXT NOT NULL,
    user_id TEXT,
    session_id TEXT NOT NULL,
    properties JSONB,
    device_info JSONB,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_events_event_name ON events(event_name);
CREATE INDEX idx_events_user_id ON events(user_id);
CREATE INDEX idx_events_session_id ON events(session_id);
CREATE INDEX idx_events_timestamp ON events(timestamp DESC);

ALTER TABLE events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow anonymous inserts" ON events
    FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "Allow service role full access" ON events
    FOR ALL TO service_role USING (true) WITH CHECK (true);
