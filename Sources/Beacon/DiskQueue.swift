import Foundation

actor DiskQueue {
    private let fileURL: URL

    init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = caches.appendingPathComponent("Beacon", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("pending_events.json")
    }

    func save(_ events: [BeaconEvent]) {
        guard !events.isEmpty else {
            try? FileManager.default.removeItem(at: fileURL)
            return
        }
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(events)
            try data.write(to: fileURL, options: .atomic)
            BeaconLogger.log("Persisted \(events.count) events to disk")
        } catch {
            BeaconLogger.error("Failed to persist events: \(error.localizedDescription)")
        }
    }

    func load() -> [BeaconEvent] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let events = try decoder.decode([BeaconEvent].self, from: data)
            try FileManager.default.removeItem(at: fileURL)
            BeaconLogger.log("Loaded \(events.count) persisted events from disk")
            return events
        } catch {
            BeaconLogger.error("Failed to load persisted events: \(error.localizedDescription)")
            return []
        }
    }
}
