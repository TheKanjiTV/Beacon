import Foundation
import PostgREST

actor BeaconClient {
    nonisolated static let shared = BeaconClient()

    private var config: BeaconConfiguration?
    private var eventQueue: EventQueue?
    private var userId: String?
    private let sessionId: String = UUID().uuidString

    private init() {}

    func configure(_ config: BeaconConfiguration) async {
        self.config = config

        let client = PostgrestClient(
            url: config.supabaseURL.appendingPathComponent("rest/v1"),
            schema: "public",
            headers: [
                "apikey": config.supabaseKey,
                "Authorization": "Bearer \(config.supabaseKey)"
            ],
            logger: nil
        )

        let queue = EventQueue(
            client: client,
            flushAt: config.flushAt,
            flushInterval: config.flushInterval
        )
        self.eventQueue = queue
        await queue.start()
    }

    func track(_ eventName: String, properties: [String: AnyCodable]? = nil) async {
        guard let queue = eventQueue else { return }

        let event = BeaconEvent(
            eventName: eventName,
            userId: userId,
            sessionId: sessionId,
            properties: properties,
            deviceInfo: DeviceInfo.current()
        )

        await queue.add(event: event)
    }

    func identify(userId: String, traits: [String: AnyCodable]? = nil) async {
        self.userId = userId

        if let traits = traits {
            await track("identify", properties: traits)
        }
    }

    func flush() async {
        await eventQueue?.flush()
    }

    func shutdown() async {
        await eventQueue?.shutdown()
        eventQueue = nil
        config = nil
    }
}
