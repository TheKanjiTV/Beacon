import Foundation
import PostgREST

actor EventQueue {
    private var buffer: [BeaconEvent] = []
    private let client: PostgrestClient
    private let flushAt: Int
    private let flushInterval: TimeInterval
    private var timerTask: Task<Void, Never>?
    private let diskQueue = DiskQueue()

    init(client: PostgrestClient, flushAt: Int, flushInterval: TimeInterval) {
        self.client = client
        self.flushAt = flushAt
        self.flushInterval = flushInterval
    }

    func start() async {
        let persisted = await diskQueue.load()
        if !persisted.isEmpty {
            buffer.insert(contentsOf: persisted, at: 0)
            BeaconLogger.log("Restored \(persisted.count) events from previous session")
        }
        startTimer()
    }

    func add(event: BeaconEvent) async {
        buffer.append(event)
        BeaconLogger.log("Queued '\(event.eventName)' (\(buffer.count)/\(flushAt))")
        if buffer.count >= flushAt {
            await flush()
        }
    }

    func flush() async {
        guard !buffer.isEmpty else { return }
        let events = buffer
        buffer.removeAll()

        BeaconLogger.log("Flushing \(events.count) events...")

        do {
            try await client.from("events").insert(events).execute()
            BeaconLogger.log("Flushed \(events.count) events successfully")
            await diskQueue.save([])
        } catch {
            BeaconLogger.error("Flush failed: \(error.localizedDescription) — re-queuing \(events.count) events")
            buffer.insert(contentsOf: events, at: 0)
            await diskQueue.save(buffer)
        }
    }

    func shutdown() async {
        timerTask?.cancel()
        timerTask = nil
        await flush()
        if !buffer.isEmpty {
            await diskQueue.save(buffer)
        }
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
