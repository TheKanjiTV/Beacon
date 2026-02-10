import Foundation

public enum Beacon {
    public static func configure(
        supabaseURL: String,
        supabaseKey: String,
        flushAt: Int = 20,
        flushInterval: TimeInterval = 30
    ) {
        guard let url = URL(string: supabaseURL) else { return }
        let config = BeaconConfiguration(
            supabaseURL: url,
            supabaseKey: supabaseKey,
            flushAt: flushAt,
            flushInterval: flushInterval
        )
        Task { await BeaconClient.shared.configure(config) }
    }

    public static func track(_ name: String, properties: [String: Any]? = nil) {
        let codableProps = properties.map { dict in
            dict.mapValues { AnyCodable($0 as any Sendable) }
        }
        Task { await BeaconClient.shared.track(name, properties: codableProps) }
    }

    public static func identify(userId: String, traits: [String: Any]? = nil) {
        let codableTraits = traits.map { dict in
            dict.mapValues { AnyCodable($0 as any Sendable) }
        }
        Task { await BeaconClient.shared.identify(userId: userId, traits: codableTraits) }
    }

    public static func flush() {
        Task { await BeaconClient.shared.flush() }
    }

    public static func shutdown() {
        Task { await BeaconClient.shared.shutdown() }
    }

    public static func enableLogging(_ enabled: Bool = true) {
        BeaconLogger.isEnabled = enabled
    }
}
