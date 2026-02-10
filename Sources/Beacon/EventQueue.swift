import Foundation
import PostgREST

actor EventQueue {
    private var buffer: [BeaconEvent] = []
    private let client: PostgrestClient
    private let flushAt: Int
    private let flushInterval: TimeInterval
    private var timerTask: Task<Void, Never>?

    init(client: PostgrestClient, flushAt: Int, flushInterval: TimeInterval) {
        self.client = client
        self.flushAt = flushAt
        self.flushInterval = flushInterval
    }

    func start() {
        startTimer()
    }

    func add(event: BeaconEvent) async {
        buffer.append(event)
        if buffer.count >= flushAt {
            await flush()
        }
    }

    func flush() async {
        guard !buffer.isEmpty else { return }
        let events = buffer
        buffer.removeAll()

        do {
            try await client.from("events").insert(events).execute()
        } catch {
            // Re-add events on failure so they aren't lost
            buffer.insert(contentsOf: events, at: 0)
        }
    }

    func shutdown() async {
        timerTask?.cancel()
        timerTask = nil
        await flush()
    }

    private func startTimer() {
        timerTask = Task { [weak self, flushInterval] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(flushInterval * 1_000_000_000))
                guard !Task.isCancelled else { break }
                await self?.flush()
            }
        }
    }
}
